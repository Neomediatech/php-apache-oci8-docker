# PHP + Apache + Oracle OCI8 Extension in a Docker container
Docker container for Apache + PHP + Oracle OCI8 Extension

This installation make use of the very old 10.1.0.5 version of Instant Client package, because of a need to connect to a 10.1 Oracle database.

## Build & Run
1. Clone this repo (or dowlload the zipped file)
2. Build with `docker build . -t php-oracle` (use whatever name you want instead of "php-oracle")
3. Run with `docker run -p 10080:80 --name my-php-oracle -d php-oracle`. "my-php-oracle" is the container name, "php-oracle" is the image name just built.

## Notes
apache.conf file contains this section:
```
<Directory /var/www/html>
  <Files report.php>
    AuthType Basic
    AuthName "Only Super Users, please"
    AuthBasicProvider file
    AuthUserFile "/var/www/html/.pwd"
    Require valid-user
  </Files>
</Directory>
```
You can delete it if you don't need Basic authentication. But if you want to use it you need to put a ".pwd" file in /var/www/html container folder (or mount it with the -v option)

## Licensing
Maybe there's some problem to host Oracle packages in this repo. In this case I'll remove them and they will be available on official download site (https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html) (or search for "Instant Client Downloads for Linux").
