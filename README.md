Action Controller Tweaks
===========

ActionController is great, but could be better. Here are some tweaks for it.

### Support
===========
Tested against:
- Action Controller of version `3.2`, `4.0`, `4.1` (`3.1` and below got problem with buggy `rspec-rails`)
- Ruby `1.9.2`, `1.9.3`, `2.0.0`, `2.1.1` (except Rails 4 with `1.9.2`)

[![Build Status](http://img.shields.io/travis/PikachuEXE/action_controller_tweaks.svg)](https://travis-ci.org/PikachuEXE/action_controller_tweaks)
[![Gem Version](http://img.shields.io/gem/v/action_controller_tweaks.svg)](http://badge.fury.io/rb/action_controller_tweaks)
[![Dependency Status](http://img.shields.io/gemnasium/PikachuEXE/action_controller_tweaks.svg)](https://gemnasium.com/PikachuEXE/action_controller_tweaks)
[![Coverage Status](http://img.shields.io/coveralls/PikachuEXE/action_controller_tweaks.svg)](https://coveralls.io/r/PikachuEXE/action_controller_tweaks)
[![Code Climate](http://img.shields.io/codeclimate/github/PikachuEXE/action_controller_tweaks.svg)](https://codeclimate.com/github/PikachuEXE/action_controller_tweaks)

Install
=======

```ruby
gem 'action_controller_tweaks'
```

Usage
=====

Either include it in specific controller or just `ApplicationController`
```ruby
class SomeController
  include ActionControllerTweaks
end 
```

### `#set_no_cache`
I got the code from [This Stack Overflow Answer](http://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails)  
`#expires_now` is not good enough when I test a mobile version page with Chrome on iOS  
Usage:
```ruby
  # Just like using #expires_now
  set_no_cache
```

### `#set_session` & `#set_session_with_expiry`
I write this on my own, it's ok to blame me if it's buggy :P  
This method let's you set session, with expiry time!  
It depends on `before_filter`/`before_action` to remove expired session keys  
Valid options: `expire_in`, `expires_in`, `expire_at`, `expires_at`
Example:
```ruby
# Option keys are NOT checked
set_session(:key, 'value') # => Just like session[:key] = 'value'

set_session(:key, 'value', expire_in: 1.day)
set_session(:key, 'value', expires_in: 1.day)

set_session(:key, 'value', expire_at: 1.day.from_now)
set_session(:key, 'value', expires_at: 1.day.from_now)

# Option keys are checked
# You must pass valid options or error will be raised
set_session_with_expiry(:key, 'value', expires_in: 1.day)
```
Note: Please don't use the session key `session_keys_to_expire`, it's reserved for internal processing
