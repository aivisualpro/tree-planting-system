import http from 'k6/http';
import { sleep, check } from 'k6';

/**
 * Simulate "Monday morning" peak: 300 field users all syncing at 8am simultaneously.
 * Target: Assess storage upload throughput and sync pushing API.
 */

export const options = {
  stages: [
    { duration: '2m', target: 300 }, // Ramp up to 300 users
    { duration: '10m', target: 300 }, // Hold at 300 concurrent users
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'], // 95% of requests must complete below 1000ms
    http_req_failed: ['rate<0.01'],    // Error rate must be less than 1%
  },
};

// Simulated mock payload representing a full visit synchronization payload
const syncPayload = JSON.stringify({
  action: 'sync_push',
  visits: [
    {
      id: 'uuid-1',
      farmer_name: 'Test Farmer',
      species: ['Mango', 'Avocado'],
      location: { lat: -1.2921, lng: 36.8219 },
      timestamp: new Date().toISOString()
    }
  ],
  media_count: 2
});

export default function () {
  const url = 'http://localhost:3000/api/sync';
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer MOCK_TOKEN`, // In a real test, feed actual tokens
    },
  };

  const res = http.post(url, syncPayload, params);
  
  check(res, {
    'status is 200 or 201': (r) => r.status === 200 || r.status === 201,
  });

  // Users don't sync constantly, they sync and then wait.
  // We simulate a user hitting sync, then doing something else for 5-15 seconds.
  sleep(Math.random() * 10 + 5);
}
