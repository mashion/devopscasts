# Method from https://gist.github.com/637579

%w(postgresql postgresql-client).each do |dependency|
  package dependency
end

bash "create db user" do
  code <<-BASH
    sudo -u postgres createuser -U postgres -SDRw reconnoiter
  BASH
  only_if %{test `echo "SELECT COUNT(*) FROM pg_user WHERE usename='reconnoiter'" | sudo -u postgres psql 2>/dev/null | head -3 | tail -1` -eq 0}
end

bash "create database" do
  code <<-BASH
    sudo -u postgres createdb -U postgres -O reconnoiter -E utf8 -T template0 reconnoiter
  BASH
  only_if %{test `echo "SELECT COUNT(*) FROM pg_database WHERE datname='reconnoiter'" | sudo -u postgres psql 2>/dev/null | head -3 | tail -1` -eq 0}
end
