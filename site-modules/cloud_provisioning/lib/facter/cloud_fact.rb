# Know if awscli,azcli and terraform is installed
Facter.add(:terraform) do
    confine :kernel => 'Linux'
    setcode do
      ret = Facter::Util::Resolution.exec('which terraform &>/dev/null && echo "yes" || echo "no"')
    end
end

Facter.add(:awscli) do
    confine :kernel => 'Linux'
    setcode do
      ret = Facter::Util::Resolution.exec('which aws &>/dev/null && echo "yes" || echo "no"')
    end
end

Facter.add(:azurecli) do
    confine :kernel => 'Linux'
    setcode do
      ret = Facter::Util::Resolution.exec('which az &>/dev/null && echo "yes" || echo "no"')
    end
end