# 安裝環境
推薦使用 venv
(optional) python -m venv LLM
(optional) source LLM/bin/activate (linux)
pip install -r requirment.txt

# 開始服務
若 docs 有更新，請刪除 storage 重新 embed
uvicorn final:app --reload

# API使用方法
1. 文字輸入
curl -X POST "http://127.0.0.1:8000/query-location" -F "location_name={location_name}"
ex. curl -X POST "http://127.0.0.1:8000/query-location" -F "location_name=Taipei 101"
2. 圖片輸入
curl -X POST "http://127.0.0.1:8000/upload-image/" -F "file=@/home/t1nf/codefest/Taipei 101 Tower-E_0.jpg"
> 請提供圖片完整位置，相對路徑可能有bug