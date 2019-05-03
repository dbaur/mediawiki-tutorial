'use strict';

const aws = require('aws-sdk');
var ssm = new aws.SSM();

const getParam = param => {
  return new Promise((res, rej) => {
    ssm.getParameter({
      Name: param
    }, (err, data) => {
      if (err) {
        return rej(err)
      }
      return res(data)
    })
})
}

const writeParam = (param, value) => {
  return new Promise((res, rej) => {
    ssm.putParameter({
      Name: param,
      Type: "String",
      Value: value,
      Overwrite: true
    }, (err, data) => {
      if (err) {
        return rej(err)
      }
      return res(data)
    })
})
}


module.exports.function = async (event, context, callback) => {

  console.log("Event: "+JSON.stringify(event));
  console.log("Context: "+JSON.stringify(context));

  var method = event.httpMethod;
  var body = event.body;

  if(method === "GET") {
    const param = await getParam('wordcount')
    console.log(param);
    return {
      statusCode: 200,
      body: JSON.stringify(param)
    };
  } else if (method === "POST") {


    var parsed = JSON.parse(body);

    const write = await writeParam('wordcount',parsed.value)
    console.log(write);
    const read = await getParam('wordcount')
    return {
      statusCode: 200,
      body: JSON.stringify(read)
    };
  } else {
    return {
      statusCode: 501,
      body: JSON.stringify("Request method "+method+" is not supported.")
    };
  }
};

