import os
import sys
import urllib.request
import zipfile
import subprocess
import shutil

# Cấu hình đường dẫn
WORKSPACE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BACKEND_DIR = os.path.join(WORKSPACE_DIR, "backend_api")
TEMP_NODE_DIR = os.path.join(WORKSPACE_DIR, "graph_database", "node_portable_temp")
ZIP_PATH = os.path.join(WORKSPACE_DIR, "graph_database", "node_portable.zip")

# URL tải Node.js portable cho Windows (bản rút gọn 64-bit)
NODE_ZIP_URL = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip"

def download_node():
    print("1. Dang tai Node.js Portable tu nodejs.org (khoang 30MB)...")
    if os.path.exists(ZIP_PATH):
        print("-> File zip da co san, bo qua buoc tai.")
        return True
        
    try:
        # Bỏ qua xác thực SSL nếu bị lỗi cert trên Windows
        import ssl
        ctx = ssl._create_unverified_context()
        
        with urllib.request.urlopen(NODE_ZIP_URL, context=ctx) as response, open(ZIP_PATH, 'wb') as out_file:
            shutil.copyfileobj(response, out_file)
        print("-> Tai Node.js thanh cong!")
        return True
    except Exception as e:
        print(f"[Error] Khong the tai Node.js: {e}")
        return False

def extract_node():
    print("\n2. Dang giai nen Node.js Portable...")
    if os.path.exists(TEMP_NODE_DIR):
        shutil.rmtree(TEMP_NODE_DIR)
        
    try:
        with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(TEMP_NODE_DIR)
        print("-> Giai nen hoan tat!")
        return True
    except Exception as e:
        print(f"[Error] Loi giai nen: {e}")
        return False

def run_npm_install():
    print("\n3. Dang chay 'npm install' cho backend_api bang Node portable...")
    
    # Tìm thư mục node vừa giải nén (nó thường nằm trong thư mục con node-v20.11.0-win-x64)
    extracted_dirs = os.listdir(TEMP_NODE_DIR)
    if not extracted_dirs:
        print("[Error] Khong tim thay thu muc con sau khi giai nen.")
        return False
        
    node_bin_dir = os.path.join(TEMP_NODE_DIR, extracted_dirs[0])
    node_exe = os.path.join(node_bin_dir, "node.exe")
    
    # Nhấp thẳng vào file cli của npm nằm trong node_modules của bản portable
    npm_cli_js = os.path.join(node_bin_dir, "node_modules", "npm", "bin", "npm-cli.js")
    
    if not os.path.exists(node_exe) or not os.path.exists(npm_cli_js):
        print(f"[Error] Khong tim thay file thuc thi Node.js hoac npm tai: {node_bin_dir}")
        return False
        
    print(f"-> Thu muc Node thuc thi: {node_bin_dir}")
    
    # Chạy lệnh: node.exe [npm-cli.js] install
    cmd = [node_exe, npm_cli_js, "install"]
    try:
        print("Dang cai dat cac module (cors, dotenv, express, mysql2)... Vui long cho...")
        # Thêm biến môi trường để npm chạy cô lập không bị ảnh hưởng bởi cấu hình hỏng trên máy
        env = os.environ.copy()
        env.pop("npm_config_prefix", None)
        env.pop("NPM_CONFIG_PREFIX", None)
        
        result = subprocess.run(
            cmd, 
            cwd=BACKEND_DIR, 
            env=env,
            shell=True,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("-> Cai dat cac npm package cho backend_api THANH CONG!")
            print(result.stdout)
            return True
        else:
            print("[Error] Chay npm install that bai.")
            print("Stderr:", result.stderr)
            print("Stdout:", result.stdout)
            return False
            
    except Exception as e:
        print(f"[Error] Loi khi goi tien trinh: {e}")
        return False

def cleanup():
    print("\n4. Dang don dep cac tep tin tam thoi...")
    try:
        if os.path.exists(ZIP_PATH):
            os.remove(ZIP_PATH)
        if os.path.exists(TEMP_NODE_DIR):
            shutil.rmtree(TEMP_NODE_DIR)
        print("-> Don dep hoan tat!")
    except Exception as e:
        print(f"[Warning] Khong the xoa file tam: {e}")

if __name__ == "__main__":
    print("=== TIEN TRINH TAI VA CAI DAT PACKAGES CHO BACKEND ===")
    
    if download_node():
        if extract_node():
            if run_npm_install():
                print("\n=== TAT CA MODULES NODEJS DA DUOC CAI DAT XONG! ===")
            cleanup()
