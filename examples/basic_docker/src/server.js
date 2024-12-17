// npm install @types/node --save-dev
import {createServer} from 'node:http';

const server = createServer((req, res) => {
    let body = '';

    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        console.log(`Method: ${req.method}`);
        console.log(`Url: ${req.url}`);
        console.log('Headers:');
        console.log(req.headers);
        console.log('Body:');
        console.log(body);

        res.writeHead(200, {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': 'http://localhost:5000'
        });
        res.end(JSON.stringify({message: 'Hello'}));
    });
});

server.listen(3000, '0.0.0.0', () => {
    console.log('Listening on 0.0.0.0:3000');
});
