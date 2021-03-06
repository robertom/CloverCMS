set :use_sudo,        false
set :group_writable,  false
set :keep_releases,   2

set :application, "clovercms"
set :domain,      "tjruby.org"
set :user,        "tjruby"

set :scm,         :git
set :repository,  "git://github.com/EnriqueVidal/CloverCMS.git"
set :branch,      "master"
set :deploy_to,   "/home/#{user}/etc/rails_apps/#{application}"

role :app,  domain
role :web,  domain
role :db,   domain, :primary => true

namespace :deploy do
  
  desc <<-DESC
    Deploys and starts a `cold' application. This is useful if you have not \
    deployed your application before, or if your application is (for some \
    other reason) not currently running. It will deploy the code, run any \
    pending migrations, and then instead of invoking `deploy:restart', it will \
    invoke `deploy:start' to fire up the application servers.
  DESC

  task :cold do
    update
    put File.read(File.join(File.dirname(__FILE__), 'database.yml')),         File.join(current_release, 'config', 'database.yml')
    put File.read(File.join(File.dirname(__FILE__), '../public/.htaccess')),  File.join(current_release, 'public', '.htaccess')
    cloverinteractive::create_shared_folders
    cloverinteractive::fix_missing_gems_and_db
    cloverinteractive::link_public_html
    cloverinteractive::restart_txt
  end
  
  desc "Restart Passenger app"
  task :restart do
    cloverinteractive::restart_txt
  end
 
  namespace :cloverinteractive do
    
    desc "It install all the missing gems needed for our app"
    task :fix_missing_gems_and_db do
      run "cd #{deploy_to}/current && bundle install --without=development && RAILS_ENV=production rake db:create db:schema:load &> ~/deploy.log"
    end
    
    desc "Links public_html to current_release/public"
    task :link_public_html do
      run "cd /home/#{user};unlink www; ln -s #{current_path}/public www; unlink public_html; ln -s www public_html"
    end
 
    desc "Create log folder in shared"
    task :create_shared_folders do
      run "cd #{deploy_to}; mkdir -p shared/log shared/system shared/pids"
    end
 
    desc "Touches tmp/restart.txt"
    task :restart_txt do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end
end
