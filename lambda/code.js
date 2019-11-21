'use strict';

const request = require('request');

const url = process.env.PUBLIC_RESTREQKV;

const getParam = param => {

  var options = {
    url: 'http://' + url + ':8080/kv/' + param,
    headers: {
      'Accept': 'application/json'
    }
  };

  return new Promise((res, rej) => {
    request.get(options, function (err, resp, body) {
      if (err) {
        rej(err);
      } else {
        res(body);
      }
    })
  })
}

const writeParam = (param, value) => {

  var options = {
    url: 'http://' + url + ':8080/kv/' + param,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: value
  };

  return new Promise((res, rej) => {
    request.put(options, function (err, resp, body) {
      if (err) {
        rej(err);
      } else {
        res(body);
      }
    })
  })
}

module.exports.function = async (event, context, callback) => {

  console.log("Event: " + JSON.stringify(event));
  console.log("Context: " + JSON.stringify(context));

  var method = event.httpMethod;
  var body = event.body;

  if (method === "GET") {
    const param = await getParam('wordcount')
    console.log(param);
    return {
      statusCode: 200,
      body: JSON.stringify(param)
    };
  } else if (method === "POST") {

    var parsed = JSON.parse(body);

    const write = await writeParam('wordcount', parsed.value)
    console.log(write);
    const read = await getParam('wordcount')
    return {
      statusCode: 200,
      body: JSON.stringify(read)
    };
  } else {
    return {
      statusCode: 501,
      body: JSON.stringify("Request method " + method + " is not supported.")
    };
  }
};

