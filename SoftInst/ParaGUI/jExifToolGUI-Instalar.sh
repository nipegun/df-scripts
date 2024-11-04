
vUltVerGuitHub=$(curl -sL https://github.com/hvdwolf/jExifToolGUI/releases/latest/ | sed 's->->\n-g' | grep elease | grep itle | head -n1 | cut -d' ' -f3)
mkdir -p /root/SoftInst/jExifToolGUI/
curl -L https://github.com/hvdwolf/jExifToolGUI/releases/download/$vUltVerGuitHub/jexiftoolgui-$vUltVerGuitHub.deb -o /root/SoftInst/jExifToolGUI/jExifToolGUI.deb
apt -y install /root/SoftInst/jExifToolGUI/jExifToolGUI.deb
