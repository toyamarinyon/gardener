gulp   = require 'gulp'
coffee = require 'gulp-coffee'
shell  = require 'gulp-shell'
webserver   = require 'gulp-webserver'

gulp.task 'default', ['build:coffee']
gulp.task 'development', ['webserver','build:coffee'], ->
  gulp.watch 'src/**/*.coffee', ['build:coffee']

gulp.task 'build:coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee
      bare: true
    .pipe gulp.dest('Commands')

gulp.task 'build:zxp', shell.task [
  '/Applications/Adobe\\ Extension\\ Manager\\ CS6/Adobe\\ Extension\\ Manager\\ CS6.app/Contents/MacOS/Adobe\\ Extension\\ Manager\\ CS6 -suppress -package mxi="./Gardener.mxi" zxp="Gardener.zxp"'
]

gulp.task 'install', shell.task [
  '/Applications/Adobe\\ Extension\\ Manager\\ CC/Adobe\\ Extension\\ Manager\\ CC.app/Contents/MacOS/Adobe\\ Extension\\ Manager\\ CC -suppress -install zxp="Gardener.zxp"'
]

gulp.task 'webserver', ->
  gulp.src './'
    .pipe webserver
      livereload:
        enable: true
        filter: (filename) ->
          filename.match /Commands/
      host: '0.0.0.0'
