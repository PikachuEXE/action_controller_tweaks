### Changelog


- **Unreleased**
  - Call `before_action` on included class if exists
  - Raise error if both `before_action` and `before_filter` does not exists

- **0.3.1**
  - Fix session key still gets deleted when no option is set
  - Fix options not passed to `#set_session` when `#set_session_with_expiry` is called

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
