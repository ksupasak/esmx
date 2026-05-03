# Vulnerability Assessment Report
**Application:** ESMX Rails 6.1.7.8 / Ruby 3.1.3  
**Scan Date:** 2026-04-08  
**Tools Used:** bundler-audit 0.9.3, brakeman 7.1.1, manual grep analysis  

---

## Summary Statistics

| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Gem Vulnerabilities (bundle-audit) | 1 | 10 | 19 | 1 |
| Brakeman Code Issues | 0 | 22 | 11 | 0 |
| Hardcoded Secrets | 0 | 2 | 0 | 0 |
| Configuration Issues | 0 | 3 | 2 | 2 |
| **Total** | **1** | **37** | **32** | **3** |

---

## CRITICAL

### C-1: redis-store 1.3.0 — Unsafe Object Deserialization (CVE-2017-1000248)
- **Gem:** redis-store 1.3.0
- **CVSS:** Critical
- **Issue:** Unsafe objects (including arbitrary Ruby classes) can be deserialized from Redis, enabling Remote Code Execution if an attacker can write to Redis.
- **Fix Required:** Update redis-store to >= 1.4.0.
- **Status:** NOT FIXED (gem version change required).

---

## HIGH

### H-1: Hardcoded Secret Token in Version Control (Brakeman: Session Setting)
- **File:** config/initializers/secret_token.rb lines 7-8
- **Issue:** config.secret_token and config.secret_key_base were hardcoded as plain strings committed to the repository. Anyone with repo access can forge session cookies.
- **Status:** FIXED — replaced with ENV.fetch('SECRET_TOKEN') and ENV.fetch('SECRET_KEY_BASE').

### H-2: Global Mass Assignment Enabled (Brakeman: Mass Assignment)
- **File:** app/controllers/application_controller.rb line 5
- **Issue:** ActionController::Parameters.permit_all_parameters = true globally disables strong parameters protection.
- **Status:** FIXED — line removed.

### H-3: CSRF Protection Configured Without Exception (Brakeman: CSRF)
- **File:** app/controllers/application_controller.rb
- **Issue:** protect_from_forgery without with: :exception silently resets session on CSRF failure.
- **Status:** FIXED — changed to protect_from_forgery with: :exception.

### H-4: Detailed Exceptions Enabled in Production (Brakeman: Information Disclosure)
- **File:** config/environments/production.rb
- **Issue:** config.consider_all_requests_local = true renders full stack traces to all users in production.
- **Status:** FIXED — changed to false.

### H-5: force_ssl Disabled in Production
- **File:** config/environments/production.rb
- **Issue:** config.force_ssl = true was commented out.
- **Status:** FIXED — uncommented.

### H-6: Command Injection — esm_attachments_controller (Brakeman: Command Injection)
- **File:** app/controllers/esm_attachments_controller.rb:67
- **Issue:** Backtick execution with user-controlled params: `convert -resize #{size} #{fname} #{rname}`
- **Status:** NOT FIXED. Use Open3.capture2e with array arguments.

### H-7: Command Injection — esm_image_controller (Brakeman: Command Injection)
- **File:** app/controllers/esm_image_controller.rb:127
- **Issue:** `zip #{tarfile} #{atts.join(" ")}` — user-controlled filenames injected into shell command.
- **Status:** NOT FIXED. Use Open3 with array arguments.

### H-8: Dangerous Eval — Parameter Value Evaluated as Code (Brakeman: Dangerous Eval)
- **File:** app/controllers/manage_controller.rb:11
- **Issue:** User-supplied parameter passed to eval(), enabling Remote Code Execution.
- **Status:** NOT FIXED. Remove eval; use a safe dispatch table.

### H-9: Dangerous Send — User Controlled Method Execution (Brakeman: Dangerous Send)
- **Files:** app/controllers/esm_proxy_controller.rb:105, 188, 244
- **Issue:** obj.send(params[:opt], ...) allows calling any method including destructive private ones.
- **Status:** NOT FIXED. Use an explicit allowlist of safe method names.

### H-10: Multiple Open Redirects (Brakeman: Redirect — 6 locations)
- **Files:** esm_controller.rb:168, user_controller.rb:125/133/137/179, home_controller.rb:85, esm_proxy_controller.rb:143
- **Issue:** Redirect destinations from user-controlled params without validation.
- **Status:** NOT FIXED. Validate redirect targets against an allowlist of trusted hosts.

### H-11: Default Routes Expose All Controller Actions (Brakeman: Default Routes)
- **File:** config/routes.rb:186
- **Issue:** Wildcard route exposes all public controller methods as routable actions.
- **Status:** NOT FIXED. Remove default route; define explicit routes.

### H-12: rack 2.2.6.2 — Multiple High-Severity Vulnerabilities (12 CVEs)
- Directory Traversal (CVE-2026-22860), Local File Inclusion in Rack::Static (CVE-2025-27610),
  multiple DoS via multipart parser (CVE-2025-61770/61771/61772/61919), params_limit bypass (CVE-2025-59830)
- **Fix Required:** Update rack to >= 2.2.22.
- **Status:** NOT FIXED (gem update required).

### H-13: rexml 3.2.5 — ReDoS Vulnerability (CVE-2024-49761, High)
- **Fix Required:** Update rexml to >= 3.3.9.
- **Status:** NOT FIXED (gem update required).

### H-14: nokogiri 1.14.2 — Multiple CVEs including High (libxslt)
- **Fix Required:** Update nokogiri to >= 1.19.2.
- **Status:** NOT FIXED (gem update required).

### H-15: Rails 6.1 End-of-Life (Brakeman: Unmaintained Dependency)
- **Issue:** Rails 6.1 EOL was 2024-10-01. No further security patches.
- **Fix Required:** Upgrade to Rails 7.2 or 8.0.
- **Status:** NOT FIXED (major upgrade required).

---

## MEDIUM

### M-1: Missing Security Headers in Nginx
- **Issue:** No X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, HSTS, Referrer-Policy.
- **Status:** FIXED — added all headers to the HTTPS server block.

### M-2: Weak SSL Cipher Suite in Nginx
- **Issue:** ssl_ciphers HIGH:!aNULL:!MD5 too broad; missing ssl_prefer_server_ciphers, session caching.
- **Status:** FIXED — replaced with modern ECDHE+CHACHA20 suite; added ssl_prefer_server_ciphers, ssl_session_cache, ssl_session_tickets off.

### M-3: CSRF Exemptions on Upload/Webhook Endpoints
- **Files:** esm_attachments_controller.rb (:upload), esm_image_controller.rb (:snap,:recover), media/recordings_controller.rb (:recording_complete)
- **Issue:** CSRF disabled; these should use token-based authentication instead.
- **Status:** NOT FIXED (requires design review).

### M-4: XSS in jquery-ui-rails 6.0.1 (CVE-2021-41182/41183/41184, CVE-2022-31160)
- **Fix Required:** Update jquery-ui-rails to >= 8.0.0.
- **Status:** NOT FIXED (gem update required).

### M-5: Unescaped Output / XSS in Views (Brakeman: XSS — 3 locations)
- **Files:** app/views/esm_documents/_render_field.html.erb:267, home_controller.rb:104, user_controller.rb:254
- **Status:** NOT FIXED.

### M-6: File Access via Model Attribute — Path Traversal Risk (Brakeman: File Access — 6 locations)
- **File:** app/controllers/esm_attachments_controller.rb:60,68,76,77,96,97
- **Status:** NOT FIXED (requires path sanitization).

### M-7: puma 6.1.0 — HTTP Request Smuggling (CVE-2023-40175, CVE-2024-21647, CVE-2024-45614)
- **Fix Required:** Update puma to >= 7.2.0.
- **Status:** NOT FIXED (gem update required).

### M-8: sidekiq 7.0.9 — DoS Vulnerability (CVE-2023-26141)
- **Fix Required:** Update sidekiq to >= 7.1.3.
- **Status:** NOT FIXED (gem update required).

### M-9: net-imap 0.3.4 — DoS via Memory Exhaustion (CVE-2025-25186, CVE-2025-43857)
- **Fix Required:** Update net-imap.
- **Status:** NOT FIXED (gem update required).

### M-10: rexml 3.2.5 — Multiple DoS CVEs (Medium severity)
- CVE-2024-35176, CVE-2024-39908, CVE-2024-41123, CVE-2024-41946, CVE-2024-43398
- **Fix Required:** Update rexml to >= 3.3.9.
- **Status:** NOT FIXED (gem update required).

### M-11: permit! Usage — Mass Assignment (Brakeman)
- **File:** app/controllers/esm_proxy_controller.rb:105
- **Issue:** params.permit! allows all parameters.
- **Status:** NOT FIXED (requires explicit permit lists per action).

### M-12: Dangerous Eval in View Template (Brakeman: Dangerous Eval)
- **File:** app/views/esm_documents/_render_containers.html.erb:406
- **Status:** NOT FIXED (requires template redesign).

---

## LOW

### L-1: XSS in link_to href (Brakeman)
- **File:** app/views/esm/scaffold/edit.html.erb:5
- **Status:** NOT FIXED (validate/sanitize URL before rendering).

### L-2: thor 1.2.1 — Unsafe Shell Command (CVE-2025-54314)
- **Fix Required:** Update thor to >= 1.4.0.
- **Status:** NOT FIXED (gem update required).

### L-3: curl --insecure in pdf_generator.rb (Command Injection / TLS bypass)
- **File:** app/models/workers/pdf_generator.rb:30
- **Issue:** Uses --insecure flag (disables TLS verification) and shells out to curl with interpolated URL.
- **Status:** NOT FIXED. Remove --insecure; use RestClient or Net::HTTP instead.

---

## INFO

### I-1: Exposed Docker Ports (docker-compose.yml)
- Database and internal service ports (3306, 27017, 6379, 9000/9001, 8554/1935/8888/8889/9997) bound to host.
- In production, only 80/443 should be publicly accessible. Move internal services to Docker-only networks.

### I-2: Wildcard CORS in Media Locations (nginx/default.conf)
- /hls/ and /webrtc/ blocks use Access-Control-Allow-Origin *.
- Restrict to known frontend origins in production.

### I-3: MinIO Default Credentials as Fallback
- config/initializers/minio.rb and docker-compose.yml fall back to minioadmin/minadadmin if ENV vars not set.
- Remove fallback defaults; always set credentials explicitly.

### I-4: Rails-Level CVEs in actionmailer, actionpack, actiontext, activerecord, activestorage
- Multiple CVEs in Rails 6.1.7.8 components. Minimum safe patch version is 6.1.7.9 for some; others require Rails 7+.

---

## What Was Fixed (Auto-fixes Applied)

| # | File | Change |
|---|------|--------|
| 1 | config/initializers/secret_token.rb | Removed hardcoded secrets; replaced with ENV.fetch() |
| 2 | config/environments/production.rb | Enabled config.force_ssl = true |
| 3 | config/environments/production.rb | Fixed config.consider_all_requests_local = false (was erroneously true) |
| 4 | app/controllers/application_controller.rb | Changed to protect_from_forgery with: :exception |
| 5 | app/controllers/application_controller.rb | Removed ActionController::Parameters.permit_all_parameters = true |
| 6 | nginx/default.conf | Added security headers: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, HSTS, Referrer-Policy, Permissions-Policy |
| 7 | nginx/default.conf | Replaced weak cipher suite with modern ECDHE+CHACHA20; added ssl_prefer_server_ciphers, ssl_session_cache, ssl_session_tickets off |

---

## Recommended Next Steps (Priority Order)

1. URGENT: Generate new SECRET_TOKEN and SECRET_KEY_BASE (`rails secret`) — old values are compromised. Add to .env.
2. URGENT: Update rack to >= 2.2.22 (directory traversal, LFI, multiple DoS).
3. HIGH: Update redis-store to >= 1.4.0 (Critical RCE via deserialization).
4. HIGH: Remove eval from manage_controller.rb and _render_containers.html.erb.
5. HIGH: Fix command injection in esm_attachments_controller.rb and esm_image_controller.rb.
6. HIGH: Fix Dangerous Send in esm_proxy_controller.rb (use method allowlist).
7. HIGH: Fix open redirects (validate against allowlist).
8. MEDIUM: Update nokogiri, rexml, puma, sidekiq, jquery-ui-rails, net-imap.
9. MEDIUM: Remove host port bindings for database/internal services in docker-compose.yml.
10. LONG TERM: Upgrade Rails to 7.2+ (6.1 is end-of-life).
