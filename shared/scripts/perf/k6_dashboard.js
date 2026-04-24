import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 500,
  duration: '10m',
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/dashboard');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}
