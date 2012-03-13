# Copycat #

Copycat is a Rails engine that allows editing live website copy.

## How to use ##

Add ```copycat``` to your Gemfile and run bundle.

Copycat uses a database table to store the copy items, and so it is necessary to create that:

```
rake copycat_engine:install:migrations
rake db:migrate
```

In a view, use the Rails i18N translate() method where you would like to display some editable copy:


```erb
<h1><%=t('site.index.header')%></h1>
```

Visit the page in your browser, and a Copycat translation will be created for the key. Then visit '/copycat_translations' in your browser and you can edit the value of that token.

## Deploying ##


## Developing ##

As a Rails engine, Copycat is developed using a nested dummy Rails app. After cloning the repository and running bundler, the plugin must be installed in the dummy app:

```
bundle
cd spec/dummy
rake copycat_engine:install:migrations
rake db:create db:migrate db:test:prepare
cd ../..
```

Now you can run the test suite:

```
rspec spec/
```

## License ##

Copycat is released under the MIT license. See MIT-LICENSE file.
