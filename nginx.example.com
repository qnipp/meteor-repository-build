server {
    listen 80;
    listen [::]:80; 

    # Set the name of your virtual host
    server_name example.com;

    # Replace example.com with your project name
    root /var/meteor-apps/example.com/bundle/programs/web.browser/app;

    passenger_enabled on;
    passenger_sticky_sessions on;

    # Set the approbriate directory, if you use a central METEOR_WAREHOUSE_DIR
    #passenger_env_var METEOR_WAREHOUSE_DIR /opt/meteor;

    # Set your database server
    passenger_env_var MONGO_URL mongodb://localhost:27017/example;
    passenger_env_var MONGO_OPLOG_URL mongodb://localhost:27017/local;

    passenger_env_var ROOT_URL http://example.com;

    # Set your SMTP server to deliver email
    passenger_env_var MAIL_URL smtp://localhost:25/;

    # Store the content of production.json here
    passenger_env_var METEOR_SETTINGS '
{
  "some_options": {
    "key": "value"
  }
}
';

    # Use the node version determined after building
    passenger_nodejs /var/meteor-apps/example.com/node;

    passenger_app_type node;
    passenger_startup_file ../../main.js;
}
