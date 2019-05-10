package eu.dbaur.spark;

import com.google.common.base.Charsets;
import java.io.IOException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;
import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.impl.Log4JLogger;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.log4j.Logger;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.SparkSession;
import scala.Tuple2;

/**
 * Hello world!
 */
public class App {

  private static final Pattern SPACE = Pattern.compile(" ");
  private static final String DATABASE = "PUBLIC_SPARKREQDATABASE";
  private static final String WIKI = "PUBLIC_SPARKREQWIKI";
  private static final String FAAS = "PUBLIC_SPARKREQWORDCOUNT";
  private static final String FAAS_REQUEST_PATTERN = "{ \"value\": \"%s\"}";
  private static final Logger LOGGER = Logger.getLogger(App.class);


  public static void main(String[] args) throws ParseException, IOException {

    Options options = new Options();
    options.addOption(DATABASE, DATABASE, true,
        "URL/IP of the wiki database");
    options.addOption(WIKI, WIKI, true,
        "URL/IP of the wiki");
    options.addOption(FAAS, FAAS, true,
        "URL/IP of the wordcount faas");

    CommandLineParser parser = new BasicParser();
    final CommandLine parse = parser.parse(options, args);

    if (!parse.hasOption(DATABASE)) {
      throw new IllegalArgumentException("Argument " + DATABASE + " is required");
    }
    if (!parse.hasOption(FAAS)) {
      throw new IllegalArgumentException("Argument " + FAAS + " is required");
    }
    if (!parse.hasOption(WIKI)) {
      throw new IllegalArgumentException("Argument " + WIKI + " is required");
    }

    String database = parse.getOptionValue(DATABASE);
    String faas = parse.getOptionValue(FAAS);

    final String jdbc = generateJDBCUrl(database);

    final SparkSession sparkSession = SparkSession.builder().appName("WikiWordCount")
        .getOrCreate();

    SQLContext sqlContext = new SQLContext(sparkSession);

    final String sql = "page inner join revision on page.page_latest = revision.rev_id inner join text on revision.rev_text_id = text.old_id";

    final Dataset<Row> lines = sqlContext.read().format("jdbc").option("url", jdbc)
        .option("dbtable", sql).option("driver", "org.mariadb.jdbc.Driver").load();

    lines.printSchema();

    final Dataset<String> words = lines.flatMap(new FlatMapFunction<Row, String>() {
      public Iterator<String> call(Row row) throws Exception {
        final byte[] bytes = row.getAs("old_text");
        final String old_text = new String(bytes, Charsets.UTF_8);
        return Arrays.asList(SPACE.split(old_text)).iterator();
      }
    }, Encoders.STRING());

    LOGGER.info("#### WORD COUNT ###");

    final JavaPairRDD<String, Integer> ones = words.toJavaRDD()
        .mapToPair(s -> new Tuple2<>(s, 1));
    JavaPairRDD<String, Integer> counts = ones.reduceByKey(Integer::sum);
    List<Tuple2<String, Integer>> output = counts.collect();
    for (Tuple2<?, ?> tuple : output) {
      LOGGER.info(tuple._1() + ": " + tuple._2());
    }

    LOGGER.info("### TOTAL WORD COUNT ###");

    LOGGER.info(words.count());

    //send the wordcount to the faas app
    sendPost(faas, String.format(FAAS_REQUEST_PATTERN, words.count()));

    sparkSession.stop();
  }

  private static String generateJDBCUrl(String url) {
    return String.format("jdbc:mysql://%s:3306/wiki?user=wiki&password=password", url);
  }

  private static void sendPost(String url, String json) throws IOException {
    final CloseableHttpClient httpClient = HttpClients.createDefault();
    StringEntity requestEntity = new StringEntity(
        json,
        ContentType.APPLICATION_JSON);

    HttpPost postMethod = new HttpPost(url);
    postMethod.setEntity(requestEntity);

    HttpResponse rawResponse = httpClient.execute(postMethod);

    LOGGER.debug(rawResponse);

    httpClient.close();
  }

}
