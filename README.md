# Copycat #

Copycat is a Rails engine that lets non-developers edit live website copy.

## How to use ##

Add ```copycat``` to your Gemfile and run bundle.

Copycat uses a database table to store the copy items, and so it is necessary to create that:

```
rake copycat:install
rake db:migrate
```

Since Copycat data is stored locally on an indexed table with no foreign keys, page loads are very fast and changes appear instantly.

In a view, use the Rails i18N.translate() method where you would like to display some editable copy:


```erb
<h1><%= t('site.index.header') %></h1>
```

Visit the page in your browser, and a Copycat translation will be created for the key. Then visit '/copycat_translations' in your browser, log in with the username and password generated in `config/initializers/copycat.rb`, and you can edit the value of that token.

## Rails i18N API ##

You can read about the Rails internationalization framework [here](http://guides.rubyonrails.org/i18n.html).

## Deploying ##

If you make copy edits on a staging server and want to transfer your changes to a production server, you can download your copy as YAML on the staging server and upload it to the production server via the web interface. If you want to mass-update only a limited set of copy values, you can upload a partial YAML file that just contains the keys and values for those particular objects.

Since this process requires no code commits, non-developers can also transfer changes.

You can, however, commit Copycat's YAML export to your git repository, and if there are not pre-existing database records with the same keys, Copycat will detect them. Copycat does make the database the authoritative source of copy, but if you export Copycat translations to YAML, commit the YAML to `config/locales`, and remove Copycat from the application entirely, the website, to end users, will remain the same.

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
