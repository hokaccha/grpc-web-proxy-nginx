import { HelloRequest } from './helloworld_pb.js';
import { GreeterClient } from './helloworld_grpc_web_pb.js';

const client = new GreeterClient('http://localhost:8080', null, null);

document.getElementById('button').addEventListener('click', () => {
  const request = new HelloRequest();
  const name = document.getElementById('input').value || 'world';
  request.setName(name);
  client.sayHello(request, {}, (err, res) => {
    if (err) {
      console.log(err);
    } else {
      console.log(res);
      document.getElementById('message').textContent = res.getMessage();
    }
  });
});
