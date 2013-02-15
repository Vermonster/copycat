# Copycat #

Copycat is a Rails engine that allows users to edit live website copy.

## How to use ##

Add ```copycat``` to your Gemfile and run ```bundle install```.

Copycat uses a database table to store the copy items, and so it is necessary to create that:

```
rake copycat:install
rake db:migrate
```

Since Copycat data is stored locally on an indexed table with no foreign keys, page loads are very fast and changes appear instantly.

In a view, use the Rails i18n translate method where you would like to display some editable copy:


```erb
<h1><%= t('site.index.header') %></h1>
```

Visit the page in your browser, and a Copycat translation will be created for the key. Then visit `/copycat_translations` in your browser, log in with the username and password generated in `config/initializers/copycat.rb`, and you can edit the value of that token.

## Rails i18n API ##

You can read about the Rails internationalization framework [here](http://guides.rubyonrails.org/i18n.html).

## Deploying ##

To transfer changes from staging to production:

* Download copy as YAML on staging
* Login to Copycat on production
* Upload YAML to production

Since this process requires no code commits, non-developers can also 'deploy' copy changes.

You can also commit Copycat's YAML export, which is compatible with i18n, to your git repository.

## Routes ##

The default route to edit copy is '/copycat_translations'. This can be customized in the initializer.

The Copycat routes are configured automatically by the engine, after your Rails application's routes.rb file is run. This means that if your routes include a catchall route at the bottom, the Copycat route will be masked. In this case you can manually draw the Copycat routes prior to the catchall route with the following line in config/routes.rb:

```ruby
Rails.application.routes.draw do
  Copycat.routes(self)
end
```

## Caching empty values ##
By default, copycat will cache empty values in the database. If a lookup results to a missing translation a new copycat entry will be created with an empty value for this locale and key.
This may not be desirable, especially during development, as after the first lookup copycat will always serve the empty translation, preventing the YML files from being consulted again for this locale and key.
Changing the default behaviour can be achieved through the following setting on the initializer:

```ruby
config.create_nils = false
```

## Logging ##
Because Copycat does a SQL query for each token, it can produce a lot of noise in the log output.
Therefore by default the logger is disabled for the Copycat ActiveRecord class.
It can be enabled with the environment variable COPYCAT_DEBUG, e.g.

```bash
COPYCAT_DEBUG=1 rails s
```

## Example ##

See an example application [here](https://github.com/Vermonster/copycat-demo). 

## Developing ##

As a Rails engine, Copycat is developed using a nested dummy Rails app. After cloning the repository and running bundler, the plugin must be installed in the dummy app:

```
bundle
cd spec/dummy
rake copycat:install
rake db:create db:migrate db:test:prepare
cd ../..
```

Now you can run the test suite:

```
rspec spec/
```

## License ##

Copycat is released under the MIT license. See MIT-LICENSE file.
