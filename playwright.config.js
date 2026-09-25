const { defineConfig, devices } = require("@playwright/test")

module.exports = defineConfig({
  testDir: "./test/browser",
  fullyParallel: false,
  workers: 1,
  retries: 0,
  forbidOnly: !!process.env.CI,
  reporter: [["list"], ["html", { open: "never" }]],
  use: {
    baseURL: "http://127.0.0.1:3100",
    trace: "retain-on-failure",
    screenshot: "only-on-failure"
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "bin/rails db:prepare && bin/rails runner script/playwright_setup.rb && bin/rails tailwindcss:build && bin/rails server -b 127.0.0.1 -p 3100 -P tmp/pids/playwright.pid",
    url: "http://127.0.0.1:3100/up",
    reuseExistingServer: false,
    timeout: 120000,
    env: {
      RAILS_ENV: "test",
      ADMIN_PASSWORD: "studio-test-password",
      DATABASE_URL: "sqlite3:storage/playwright.sqlite3",
      SALON_TIME_ZONE: "America/New_York"
    }
  }
})
