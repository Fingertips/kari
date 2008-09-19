# Class that generates Karidoc files from the RI definition
class Generator
  # Returns the filename where the karidoc file for the full_name will be stored.
  #
  # Example:
  #   Generator.filename('Module::SubModule.method') => '/path/to/Module/SubModule/method.karidoc'
  def self.filename(full_name)
    Namespace.split(name).join(File::SEPARATOR) + '.karidoc'
  end
end