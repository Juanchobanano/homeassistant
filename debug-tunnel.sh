#!/bin/bash
echo "=== TWENTY CRM ==="
echo ""
echo "Container status:"
sudo docker ps --filter "name=twenty" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Recent logs (twenty-server):"
sudo docker logs twenty-server --tail 15
echo ""
echo "API test (internal):"
sudo docker exec twenty-server node -e "
  require('http').get('http://localhost:3000/healthz', r => {
    let d='';
    r.on('data', c => d += c);
    r.on('end', () => console.log('healthz status:', r.statusCode, d || '[empty]'));
  }).on('error', e => console.log('ERROR:', e.message))
"
echo ""

echo "=== CLOUDFLARE TUNNEL ==="
echo ""
echo "Container status:"
sudo docker ps --filter "name=cloudflared" --format "table {{.Names}}\t{{.Status}}"
echo ""
echo "Recent logs:"
sudo docker logs cloudflared --tail 10
echo ""

echo "=== ENV VARS ==="
echo ""
echo "SERVER_URL:"
sudo grep "^SERVER_URL" /home/juanchobanano/Documents/homeassistant/.env || echo "  Not found!"
echo ""
echo "TUNNEL_TOKEN set?"
sudo grep "^TUNNEL_TOKEN" /home/juanchobanano/Documents/homeassistant/.env | sed 's/=.*/=***hidden***/' || echo "  Not found!"
echo ""

echo "=== PORTS (host) ==="
echo ""
sudo ss -tlnp 2>/dev/null | grep -E "3001|5678|3000" || sudo netstat -tlnp 2>/dev/null | grep -E "3001|5678|3000" || echo "  Could not check ports"
