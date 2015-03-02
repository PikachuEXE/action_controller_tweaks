### Changelog


- **Unreleased**
  - Fix session key still gets deleted when no option is set

- **0.3.0**
  - Add method `#set_session_with_expiry`
  - Add option `expires_in` and `expires_at` to #set_session
  - Fix invalid header when using `#set_no_cache` for HTTP 1.0
  - Raise error when reserved session key(s) is set through the provided method

- **0.2.0**
  - Add option `expire_at` to #set_session
  - Use semantic versioning

- **0.1**
  - Initial Release
