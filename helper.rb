module Helper
  extend self

  def remove_comment_of_gem
    gsub_file('Gemfile', /^\s*#.*$\n/, '')
  end


  def remove_gem(*names)
    names.each do |name|
      gsub_file 'Gemfile', /gem '#{name}'\n/, ''
    end
  end

  def get_remote(src, dest = nil)
    dest ||= src
    repo = 'https://raw.github.com/work-design/template/master/files/'
    remote_file = repo + src
    remove_file dest
    get(remote_file, dest)
  end


end



