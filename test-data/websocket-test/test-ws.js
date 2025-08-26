const WebSocket = require('ws');

// Get Loki domain from command line argument or use default
const LOKI_DOMAIN = process.argv[2] || 'raziiuiofbxoor3budb4cw15y4uswymjw3t7d76na5en84cpw7gy.loki';

console.log(`🔌 Testing WebSocket connection to ${LOKI_DOMAIN}:8002`);
console.log(`💡 Usage: node test-loki.js [loki-domain]`);
console.log(`💡 Example: node test-loki.js mydomain.loki`);

(async () => {
    const ws = new WebSocket(`ws://${LOKI_DOMAIN}:8002/test`);

    ws.onopen = () => console.log('✅ Connected to WebSocket via .loki domain!');
    ws.onmessage = (event) => console.log('📨 Received:', event.data);
    ws.onclose = () => console.log('❌ Disconnected');
    ws.onerror = (error) => console.log('🚨 Error:', error);
})();