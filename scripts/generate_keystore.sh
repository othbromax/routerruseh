#!/usr/bin/env bash
# ============================================================================
# Route Rush — Keystore Generation Script
# ============================================================================
#
# PURPOSE:
#   Generates a Java Keystore (.jks) for signing Android release builds.
#   Outputs the keystore encoded in base64 along with the exact values
#   that must be saved as GitHub Secrets.
#
# PRIVACY GUARANTEE:
#   - Prompts ONLY for company / organisational details that YOU type in.
#   - Does NOT read any system information (hostname, username, IP, MAC, OS).
#   - Does NOT auto-fill or infer any values.
#   - Does NOT transmit anything over the network.
#   - The generated keystore file is local-only.
#
# REQUIREMENTS:
#   - Java JDK (keytool must be on PATH)
#
# USAGE:
#   bash scripts/generate_keystore.sh
# ============================================================================

set -euo pipefail

# ── Colour helpers (degrade gracefully if tput missing) ────────────────────
bold=$(tput bold 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
cyan=$(tput setaf 6 2>/dev/null || true)

echo ""
echo "${bold}============================================${reset}"
echo "${bold}  Route Rush — Keystore Generator${reset}"
echo "${bold}============================================${reset}"
echo ""
echo "${yellow}This script collects ONLY company details that you type in."
echo "It does NOT read any system, user, IP, or location data.${reset}"
echo ""

# ── Verify keytool is available ────────────────────────────────────────────
if ! command -v keytool &>/dev/null; then
    echo "ERROR: 'keytool' not found. Install a Java JDK and ensure it is on PATH."
    exit 1
fi

# ── Prompt for company details (minimum 5 fields) ─────────────────────────
prompt() {
    local var_name="$1" prompt_text="$2" value=""
    while [ -z "$value" ]; do
        read -rp "${cyan}${prompt_text}: ${reset}" value
        if [ -z "$value" ]; then
            echo "${yellow}  This field is required. Please enter a value.${reset}"
        fi
    done
    eval "$var_name='$value'"
}

echo "${bold}── Company Details ──${reset}"
echo ""
prompt COMPANY_NAME     "Company / Organisation Name  (e.g. Acme Corp)"
prompt ORG_UNIT         "Organisational Unit          (e.g. Mobile Development)"
prompt CITY             "City / Locality              (e.g. Berlin)"
prompt STATE            "State / Province             (e.g. Berlin)"
prompt COUNTRY_CODE     "Two-letter Country Code      (e.g. DE)"

echo ""
echo "${bold}── Keystore Credentials ──${reset}"
echo ""
prompt KEY_ALIAS        "Key Alias                    (e.g. upload)"

# Read passwords without echoing them to the terminal
while true; do
    read -rsp "${cyan}Keystore Password (min 6 chars): ${reset}" STORE_PASSWORD
    echo ""
    if [ ${#STORE_PASSWORD} -lt 6 ]; then
        echo "${yellow}  Password must be at least 6 characters.${reset}"
        continue
    fi
    read -rsp "${cyan}Confirm Keystore Password:       ${reset}" STORE_PASSWORD_CONFIRM
    echo ""
    if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
        echo "${yellow}  Passwords do not match. Try again.${reset}"
        continue
    fi
    break
done

while true; do
    read -rsp "${cyan}Key Password     (min 6 chars): ${reset}" KEY_PASSWORD
    echo ""
    if [ ${#KEY_PASSWORD} -lt 6 ]; then
        echo "${yellow}  Password must be at least 6 characters.${reset}"
        continue
    fi
    read -rsp "${cyan}Confirm Key Password:            ${reset}" KEY_PASSWORD_CONFIRM
    echo ""
    if [ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]; then
        echo "${yellow}  Passwords do not match. Try again.${reset}"
        continue
    fi
    break
done

# ── Build the Distinguished Name (DN) ─────────────────────────────────────
DNAME="CN=${COMPANY_NAME}, OU=${ORG_UNIT}, O=${COMPANY_NAME}, L=${CITY}, ST=${STATE}, C=${COUNTRY_CODE}"

# ── Output file ────────────────────────────────────────────────────────────
KEYSTORE_FILE="upload-keystore.jks"

# Remove any previous file so keytool doesn't prompt to overwrite
rm -f "$KEYSTORE_FILE"

echo ""
echo "${bold}Generating keystore...${reset}"
echo ""

keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

echo ""

# ── Encode to base64 ──────────────────────────────────────────────────────
KEYSTORE_BASE64=$(base64 -w 0 "$KEYSTORE_FILE" 2>/dev/null || base64 -i "$KEYSTORE_FILE" | tr -d '\n')

# ── Print instructions ────────────────────────────────────────────────────
echo "${bold}${green}============================================${reset}"
echo "${bold}${green}  Keystore generated successfully!${reset}"
echo "${bold}${green}============================================${reset}"
echo ""
echo "File: ${bold}${KEYSTORE_FILE}${reset} ($(wc -c < "$KEYSTORE_FILE") bytes)"
echo ""
echo "${bold}${yellow}──────────────────────────────────────────────────────────${reset}"
echo "${bold}${yellow}  SAVE THESE VALUES AS GITHUB SECRETS${reset}"
echo "${bold}${yellow}──────────────────────────────────────────────────────────${reset}"
echo ""
echo "Go to your GitHub repository:"
echo "  Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "Create these 4 secrets with the EXACT names and values shown below:"
echo ""
echo "${bold}Secret Name:${reset}  KEYSTORE_BASE64"
echo "${bold}Value:${reset}        (the base64 string printed below)"
echo ""
echo "${bold}Secret Name:${reset}  KEYSTORE_PASSWORD"
echo "${bold}Value:${reset}        ${STORE_PASSWORD}"
echo ""
echo "${bold}Secret Name:${reset}  KEY_ALIAS"
echo "${bold}Value:${reset}        ${KEY_ALIAS}"
echo ""
echo "${bold}Secret Name:${reset}  KEY_PASSWORD"
echo "${bold}Value:${reset}        ${KEY_PASSWORD}"
echo ""
echo "${bold}${yellow}──────────────────────────────────────────────────────────${reset}"
echo "${bold}${yellow}  BASE64 KEYSTORE VALUE (copy everything between the lines)${reset}"
echo "${bold}${yellow}──────────────────────────────────────────────────────────${reset}"
echo ""
echo "$KEYSTORE_BASE64"
echo ""
echo "${bold}${yellow}──────────────────────────────────────────────────────────${reset}"
echo ""
echo "${bold}IMPORTANT:${reset}"
echo "  1. Do NOT commit ${KEYSTORE_FILE} to version control."
echo "  2. Do NOT share the base64 string or passwords publicly."
echo "  3. After saving all 4 secrets, you can delete ${KEYSTORE_FILE} from this machine."
echo "  4. The GitHub Actions workflow will decode the keystore at build time."
echo ""
echo "${bold}${green}Done.${reset}"
