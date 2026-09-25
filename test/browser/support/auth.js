const { test: base, expect } = require("@playwright/test")
const { createHash } = require("node:crypto")

const test = base.extend({
  page: async ({ page }, use, testInfo) => {
    // Isolate IP-based login limits between independent browser scenarios.
    const ipSuffix = createHash("sha256").update(testInfo.testId).digest()[0] % 254 + 1
    await page.setExtraHTTPHeaders({ "X-Forwarded-For": `192.0.2.${ipSuffix}` })
    await page.goto("/login")
    await page.getByLabel("Username", { exact: true }).fill("admin")
    await page.getByLabel("Password", { exact: true }).fill("studio-test-password")
    await page.getByRole("button", { name: "Sign in", exact: true }).click()
    await expect(page.getByRole("button", { name: "Sign out", exact: true })).toBeVisible()
    await use(page)
  }
})

module.exports = { test, expect }
