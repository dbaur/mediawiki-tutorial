package eu.dbaur.spark;

import com.google.common.base.Charsets;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;
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

  public static void main(String[] args) {

    //todo ready from args
    String url = "134.60.64.245";

    final String jdbc = generateJDBCUrl(url);

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

    System.out.println("#### WORD COUNT ###");

    final JavaPairRDD<String, Integer> ones = words.toJavaRDD()
        .mapToPair(s -> new Tuple2<>(s, 1));
    JavaPairRDD<String, Integer> counts = ones.reduceByKey(Integer::sum);
    List<Tuple2<String, Integer>> output = counts.collect();
    for (Tuple2<?, ?> tuple : output) {
      System.out.println(tuple._1() + ": " + tuple._2());
    }

    System.out.println("### TOTAL WORD COUNT ###");

    System.out.println(words.count());

    sparkSession.stop();
  }

  private static String generateJDBCUrl(String url) {
    return String.format("jdbc:mysql://%s:3306/wiki?user=wiki&password=password", url);
  }

}
