/* eslint-disable no-console */
import { HelloRequest, CountRequest } from './helloworld_pb.js';
import { GreeterClient } from './helloworld_grpc_web_pb.js';

const client = new GreeterClient('http://localhost:8080', null, null);

document.getElementById('button').addEventListener('click', () => {
  const req = new HelloRequest();
  const name = document.getElementById('input').value || 'world';
  req.setName(name);
  client.sayHello(req, {}, (err, res) => {
    if (err) {
      console.log(err);
    } else {
      console.log(res);
      document.getElementById('message').textContent = res.getMessage();
    }
  });
});

document.getElementById('count').addEventListener('click', () => {
  const req = new CountRequest();
  req.setN(10);
  const stream = client.countStream(req, {});
  stream.on('data', res => {
    document.getElementById('count_result').textContent = res.getCount();
  });
  stream.on('status', status => {
    console.log(status);
  });
  stream.on('error', err => {
    console.log(err);
  });
  stream.on('end', () => {
    console.log('end');
  });
});
