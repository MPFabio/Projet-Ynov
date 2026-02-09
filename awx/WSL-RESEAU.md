# WSL : « Network is unreachable » / pas de réseau

Si dans WSL vous avez :
- **`ping 8.8.8.8`** → `Network is unreachable`
- **`ping archive.ubuntu.com`** → `Temporary failure in name resolution`

alors **WSL n’a pas d’accès Internet** (réseau WSL2 coupé ou mal configuré). À faire dans l’ordre :

---

## 1. Vérifier que Windows a bien Internet

Ouvrez un navigateur sous Windows et chargez un site. Si Windows n’a pas Internet, WSL ne peut pas en avoir non plus.

---

## 2. Redémarrer WSL

Dans **PowerShell** (Windows) :

```powershell
wsl --shutdown
```

Puis rouvrez **Ubuntu (WSL)** et retestez :

```bash
ping -c 1 8.8.8.8
```

Si ça répond, refaites ensuite : `ping archive.ubuntu.com`, puis `sudo apt update`.

---

## 3. Désactiver le VPN le temps du test

Certains VPN coupent le réseau WSL2. Désactivez le VPN, faites `wsl --shutdown`, rouvrez WSL et retestez `ping 8.8.8.8`.

---

## 4. Réinitialiser la pile réseau Windows (si rien ne change)

Dans **PowerShell en administrateur** :

```powershell
netsh winsock reset
netsh int ip reset
```

Puis **redémarrez Windows** (pas seulement WSL). Après le redémarrage, rouvrez WSL et retestez `ping 8.8.8.8`.

---

## 5. Vérifier l’adaptateur « vEthernet (WSL) »

- **Paramètres Windows** → **Réseau et Internet** → **Paramètres avancés** → **Plus de paramètres d’adaptateur réseau**
- Ou exécuter : **`ncpa.cpl`**
- Vérifier qu’un adaptateur du type **« vEthernet (WSL) »** ou **« Ethernet vEthernet (WSL) »** existe et n’est pas désactivé. Si besoin, clic droit → **Activer**.

---

## 6. Mettre à jour WSL (Windows 10/11)

Dans PowerShell :

```powershell
wsl --update
```

Puis `wsl --shutdown` et rouvrir WSL.

---

## 7. Solution de repli : Ansible ailleurs qu’en WSL

Si le réseau WSL reste bloqué sur votre machine :

- Utiliser une **machine virtuelle Linux** (VirtualBox, Hyper-V, etc.) avec réseau OK, y installer Ansible et lancer le playbook awx-without-k8s depuis là ; **ou**
- Utiliser un **autre PC / serveur Linux** avec Ansible et Docker pour déployer AWX.

Le playbook et l’inventaire dans `awx/` sont les mêmes ; seul l’environnement d’exécution change (WSL, VM, ou autre Linux).
