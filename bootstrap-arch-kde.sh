#!/bin/bash

install_brave_extension()
{
    local extension_id="$1"
    local extensions_path="/opt/brave-bin/extensions"

    mkdir -p "$extensions_path"

    echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' | sudo tee "${extensions_path}/${extension_id}.json" >> /dev/null
}

echo "Updating system..."
sudo pacman -Syuu > /dev/null

echo "Installing packages..."
sudo pacman -S --noconfirm --needed git gcc mingw-w64-gcc cmake ninja gdb valgrind clang discord steam wine winetricks lib32-pipewire lib32-libpulse code fish fastfetch > /dev/null

yay_temp_dir="/tmp/bootstrap-yay"
if ! pacman -Qs "yay" > /dev/null ; then
    echo "yay not found, installing..."
    mkdir "${yay_temp_dir}"
    chmod 1777 "${yay_temp_dir}"
    cd "${yay_temp_dir}"
    git clone --quiet https://aur.archlinux.org/yay-bin.git > /dev/null
    cd yay-bin
    makepkg -si > /dev/null
else
    echo "Yay already installed."
fi

echo "Installing Brave browser..."
yay -S --noconfirm brave-bin > /dev/null

echo "Installing Brave extensions..."
install_brave_extension "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
install_brave_extension "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
install_brave_extension "oeopbcgkkoapgobdbedcemjljbihmemj" # Checker Plus for Gmail
install_brave_extension "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
install_brave_extension "aalmjfpohaedoddkobnibokclgeefamn" # Gumbo
install_brave_extension "fadndhdgpmmaapbmfcknlfgcflmmmieb" # FrankerFaceZ
install_brave_extension "dneaehbmnbhcippjikoajpoabadpodje" # Old Reddit Redirect
install_brave_extension "kbmfpngjjgdllneeigpgjifpgocmfgmb" # RES
install_brave_extension "dpacanjfikmhoddligfbehkpomnbgblf" # AHA Music
install_brave_extension "jipdnfibhldikgcjhfnomkfpcebammhp" # Rikai-kun
install_brave_extension "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock

echo "Installing Code marketplace..."
yay -S --noconfirm code-oss-marketplace > /dev/null

echo "Installing Code extensions..."
code --install-extension "ms-vscode.cmake-tools"
code --install-extension "llvm-vs-code-extensions.vscode-clangd"
code --install-extension "twxs.cmake"
code --install-extension "Catppuccin.catppuccin-vsc"
code --install-extension "Catppuccin.catppuccin-vsc-icons"
code --install-extension "ms-vscode.live-server"
code --install-extension "ms-vscode.cpptools"
code --install-extension "MS-vsliveshare.vsliveshare"
code --install-extension "jeff-hykin.better-cpp-syntax"

echo "Installing fisher and tide..."
fish install_tide.fish

echo "Setting up default wine prefix with gaming components..."
winetricks vkd3d dxvk allfonts gdiplus galliumnine d3dx11_43 d3dcompiler_47 dotnet48 d3dx9_43 xna40 vcrun2022 > /dev/null

