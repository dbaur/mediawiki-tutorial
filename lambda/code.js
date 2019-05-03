'use strict';

const aws = required('aws-sdk');
var ssm = new aws.SSM();

module.exports.function = (event, context, callback) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Hello World',
    }),
  };

  callback(null, response);
};
