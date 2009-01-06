module ObjectiveC
  class CompileError < ::StandardError; end
  
  class << self
    def require(path, *frameworks)
      compile path, *frameworks
      Kernel.require bundle_path(path)
    end
    
    private
    
    def klass(path)
      File.basename(path)
    end
    
    def output_dir
      File.join Rucola::RCApp.root_path, 'build', 'bundles'
    end
    
    def ensure_output_dir!
      FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir)
    end
    
    def bundle_path(path)
      File.join output_dir, "#{klass(path)}.bundle"
    end
    
    def implementation_file(path)
      File.join Rucola::RCApp.root_path, "#{path}.m"
    end
    
    def verify_implementation_file(path)
      full_path = implementation_file(path)
      function = "void Init_#{klass(path)}"
      unless File.read(full_path).include?(function)
        raise CompileError, "Implementation file `#{full_path}' does not contain the necessary Ruby init function `#{function}() {}'."
      end
    end
    
    def compile(path, *frameworks)
      verify_implementation_file(path)
      full_path = implementation_file(path)
      ensure_output_dir!
      frameworks.unshift 'Foundation'
      
      command = "gcc -o #{bundle_path(path)} -arch x86_64 -fobjc-gc -flat_namespace -undefined suppress -bundle #{frameworks.map { |f| "-framework #{f}" }.join(' ')} -I#{File.dirname(full_path)} #{full_path}"
      unless system(command)
        raise CompileError, "Unable to compile class `#{klass(path)}' at path: `#{full_path}'."
      end
    end
  end
end