import { test, expect } from '@playwright/test';

test('login page has title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Tree Planting/);
});

test('unauthorized user redirects to login', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveURL(/.*login.*/);
});
