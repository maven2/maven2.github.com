#!/usr/bin/env ruby

SITE = '/maven2.github.com'
INDEX_HTML = 'index.html'

FOOTER=<<END
</ul>
<p>Please visit <a href="http://github.com/maven2">http://github.com/maven2</a> if you would like to publish your GitHub-hosted Maven 2 project on this repository.</p>
</body>
</html>
END

# MAIN

ROOT=`pwd`.chomp
SCRIPT=File.basename($0)

def gentoc(base)
  files = []
  dirs = []
  Dir.foreach(base) { |path|
    fq = File.join(base, path)
    if FileTest.directory?(fq)
      next if path[0, 1] == '.'
      dirs << path
    else
      next if File.basename(path) == SCRIPT || File.basename(path) == INDEX_HTML
      files << path
    end
  }
  dirs.each { |dir| gentoc(File.join(base, dir)) }
  write_index_html(base, dirs, files)
end

def write_index_html(base, dirs, files)
  puts base
  index = File.join(base, INDEX_HTML)
  l = base.length - ROOT.length - 1
  title = base[-l, l] || SITE
    
  File.open(index, 'w') { |o|
    o << <<END
<html>
<title>#{title}</title>
<body>
<h3>#{title}</h3>
<ul>
END
    unless base == ROOT
      parent = File.dirname(base).gsub(SITE, '') + '/'
      o.puts "<li><a href=\"#{parent}\">..</a></li>"
    end
    dirs.each { |dir|
      d = File.basename(dir)
      o.puts "<li><a href=\"#{d}/\">#{d}</a></li>"
    }
    files.each { |file|
      f = File.basename(file)
      o.puts "<li><a href=\"#{f}\">#{f}</a></li>"
    }
    o << FOOTER
  }
end

gentoc(ROOT)
