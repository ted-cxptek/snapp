const https = require('https');
const http = require('http');

// Get Loki domain from command line argument or use default
const LOKI_DOMAIN = process.argv[2] || 'raziiuiofbxoor3budb4cw15y4uswymjw3t7d76na5en84cpw7gy.loki';
const PORT = process.argv[3] || '3000';

console.log(`🔌 Testing HTTP API connection to ${LOKI_DOMAIN}:${PORT}`);
console.log(`💡 Usage: node test-api.js [loki-domain] [port]`);
console.log(`💡 Example: node test-api.js mydomain.loki 3000`);

// Test data for login
const loginData = {
    "password": "123123123",
    "publicKey": "123123123",
    "username": "tedcxp_2"
};

// Function to make HTTP request
function makeRequest(domain, port, path, method = 'POST', data = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: domain,
            port: port,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'Node.js API Test Client'
            }
        };

        const req = http.request(options, (res) => {
            let responseData = '';
            
            res.on('data', (chunk) => {
                responseData += chunk;
            });
            
            res.on('end', () => {
                console.log(`📡 Response Status: ${res.statusCode}`);
                console.log(`📡 Response Headers:`, res.headers);
                console.log(`📡 Response Body:`, responseData);
                
                try {
                    const jsonResponse = JSON.parse(responseData);
                    console.log(`📡 Parsed JSON:`, JSON.stringify(jsonResponse, null, 2));
                } catch (e) {
                    console.log(`📡 Raw response (not JSON):`, responseData);
                }
                
                resolve({
                    statusCode: res.statusCode,
                    headers: res.headers,
                    body: responseData
                });
            });
        });

        req.on('error', (error) => {
            console.log(`🚨 Request Error:`, error.message);
            reject(error);
        });

        if (data) {
            req.write(JSON.stringify(data));
        }
        
        req.end();
    });
}

// Test register endpoint
async function testRegister() {
    console.log(`\n🔐 Testing Register API...`);
    console.log(`📍 Endpoint: POST http://${LOKI_DOMAIN}:${PORT}/v1/auth/register`);
    console.log(`📝 Data:`, JSON.stringify(loginData, null, 2));
    
    try {
        const result = await makeRequest(LOKI_DOMAIN, PORT, '/v1/auth/register', 'POST', loginData);
        console.log(`✅ Register test completed with status: ${result.statusCode}`);
        return result;
    } catch (error) {
        console.log(`❌ Register test failed:`, error.message);
        return null;
    }
}

// Run tests
testRegister().catch(error => {
    console.error(`💥 Test execution failed:`, error);
    process.exit(1);
});
