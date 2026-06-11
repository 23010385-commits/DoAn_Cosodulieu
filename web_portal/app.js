// ============================================================================
// CẤU HÌNH ĐỊA CHỈ API
// ============================================================================
const MYSQL_API_URL = "http://localhost:3000";
const GRAPH_API_URL = "http://localhost:5000";

// Biến toàn cục lưu danh sách tiêu đề sách từ MySQL để lọc phía client
let mysqlBookTitles = new Set();

// Mapping liên kết đọc sách (Google Drive / Website) lấy từ hệ thống Firestore và mẫu
const BOOK_READ_URLS = {
    "Đắc Nhân Tâm": "https://drive.google.com/file/d/1mlIagmYc0_B7E38xHcmyEYLSZj-qlLGM/view",
    "Đọc vị khách hàng": "https://drive.google.com/file/d/18fjeyOKmilAUct_4R-MW52PPlZwrHmp6/view",
    "Nghĩ giàu và làm giàu": "https://sites.google.com/view/kho-sach-online/trang-chủ",
    "Thế giới phẳng": "https://drive.google.com/file/d/1pTGzw-WBWHMPLVnq8KYM2dF1miymPFMK/view",
    "Tuổi trẻ đáng giá bao nhiêu?": "https://nld.mediacdn.vn/zoom/700_438/2018/3/24/sach-crop-15218586503061207966396.jpg",
    "Harry Potter": "https://drive.google.com/file/d/1mlIagmYc0_B7E38xHcmyEYLSZj-qlLGM/view",
    "Cho Toi Xin Mot Ve Di Tuoi Tho": "https://drive.google.com/file/d/1hDwTGnNfNfdAqa4DVeumEBcLmwKCjUXD/view",
    "Cho Tôi Xin Một Vé Đi Tuổi Thơ": "https://drive.google.com/file/d/1hDwTGnNfNfdAqa4DVeumEBcLmwKCjUXD/view"
};

function getReadUrl(title) {
    const normalizedTitle = title.trim().toLowerCase();
    for (const key of Object.keys(BOOK_READ_URLS)) {
        if (key.trim().toLowerCase() === normalizedTitle) {
            return BOOK_READ_URLS[key];
        }
    }
    // Fallback tìm kiếm Google nếu không khớp sách cụ thể
    return `https://www.google.com/search?q=doc+sach+${encodeURIComponent(title)}`;
}


document.addEventListener("DOMContentLoaded", () => {
    // 1. Khởi chạy kiểm tra trạng thái Server & Tải danh mục sách
    checkServerStatuses();
    loadBooks();
    
    // 2. Thiết lập Tab Navigation
    initTabNavigation();
    
    // 3. Thiết lập Form Gợi ý Sách
    initRecommendationForm();
});

// ============================================================================
// HÀM KIỂM TRA TRẠNG THÁI ONLINE/OFFLINE CỦA CÁC API
// ============================================================================
async function checkServerStatuses() {
    const mysqlIndicator = document.getElementById("mysqlStatus");
    const neoIndicator = document.getElementById("neoStatus");
    
    // Kiểm tra MySQL Node.js API (cổng 3000)
    try {
        const res = await fetch(`${MYSQL_API_URL}/`);
        if (res.ok) {
            mysqlIndicator.classList.add("online");
            mysqlIndicator.classList.remove("offline");
        } else {
            throw new Error();
        }
    } catch (e) {
        mysqlIndicator.classList.add("offline");
        mysqlIndicator.classList.remove("online");
    }

    // Kiểm tra Python Graph API (cổng 5000)
    try {
        const res = await fetch(`${GRAPH_API_URL}/api/recommendations/admin`);
        if (res.ok) {
            neoIndicator.classList.add("online");
            neoIndicator.classList.remove("offline");
        } else {
            throw new Error();
        }
    } catch (e) {
        neoIndicator.classList.add("offline");
        neoIndicator.classList.remove("online");
    }
}

// ============================================================================
// TAB NAVIGATION LOGIC
// ============================================================================
function initTabNavigation() {
    const tabButtons = document.querySelectorAll(".tab-btn");
    const tabPanels = document.querySelectorAll(".tab-panel");

    tabButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            // Xóa active cũ
            tabButtons.forEach(b => b.classList.remove("active"));
            tabPanels.forEach(p => p.classList.remove("active"));
            
            // Thêm active mới
            btn.classList.add("active");
            const targetTab = btn.getAttribute("data-tab");
            document.getElementById(targetTab).classList.add("active");
        });
    });
}

// ============================================================================
// TẢI DANH MỤC SÁCH TỪ MYSQL API
// ============================================================================
async function loadBooks() {
    const tbody = document.getElementById("booksTableBody");
    const badge = document.getElementById("bookCountBadge");
    
    try {
        // Thử đường dẫn API chuẩn của Dũng trước
        let response = await fetch(`${MYSQL_API_URL}/api/books`);
        
        // Nếu lỗi 404, thử fallback về đường dẫn cũ
        if (response.status === 404) {
            response = await fetch(`${MYSQL_API_URL}/books`);
        }
        
        if (!response.ok) {
            throw new Error("Không thể kết nối đến cơ sở dữ liệu MySQL.");
        }
        
        const books = await response.json();
        
        // Cập nhật danh sách tiêu đề sách từ MySQL để lọc
        mysqlBookTitles = new Set(books.map(b => b.title.trim().toLowerCase()));
        
        if (books.length === 0) {
            tbody.innerHTML = `<tr><td colspan="4" class="text-center">Kho sách hiện đang trống.</td></tr>`;
            badge.innerText = `0 cuốn sách`;
            return;
        }
        
        tbody.innerHTML = "";
        books.forEach(book => {
            const readUrl = getReadUrl(book.title);
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td><strong>#${book.book_id}</strong></td>
                <td><a href="${readUrl}" target="_blank" class="book-link" title="Bấm vào để đọc sách">📖 ${book.title}</a></td>
                <td>${book.published_year || "N/A"}</td>
                <td>${book.publisher || "Không rõ"}</td>
            `;
            tbody.appendChild(tr);
        });

        
        badge.innerText = `${books.length} cuốn sách`;
        
    } catch (err) {
        console.error(err);
        tbody.innerHTML = `
            <tr>
                <td colspan="4" class="text-center" style="color: var(--error);">
                    ⚠️ Lỗi: Không thể kết nối tới MySQL API (Port 3000). Hãy kiểm tra xem server Node.js đã được chạy chưa.
                </td>
            </tr>
        `;
        badge.innerText = `Lỗi kết nối`;
    }
}

// ============================================================================
// HỆ GỢI Ý SÁCH (NEO4J GRAPH API)
// ============================================================================
function initRecommendationForm() {
    const form = document.getElementById("recForm");
    const input = document.getElementById("usernameInput");
    
    const loading = document.getElementById("recLoading");
    const emptyState = document.getElementById("recEmptyState");
    const resultsWrapper = document.getElementById("recResultsWrapper");
    const targetUserSpan = document.getElementById("targetUserSpan");
    const recGrid = document.getElementById("recGrid");
    const historyGrid = document.getElementById("historyGrid");

    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        
        const username = input.value.trim();
        if (!username) return;

        // Reset giao diện hiển thị
        emptyState.style.display = "none";
        resultsWrapper.style.display = "none";
        loading.style.display = "flex";
        
        try {
            const response = await fetch(`${GRAPH_API_URL}/api/recommendations/${encodeURIComponent(username)}`);
            
            if (response.status === 404) {
                loading.style.display = "none";
                recGrid.innerHTML = "";
                historyGrid.innerHTML = "";
                resultsWrapper.style.display = "block";
                targetUserSpan.innerText = username + " (Không tồn tại)";
                recGrid.innerHTML = `
                    <div style="grid-column: 1/-1; text-align: center; padding: 2rem; color: var(--warning); font-weight: 500;">
                        ⚠️ Tài khoản "${username}" không tồn tại trong hệ thống đồ thị Neo4j!
                    </div>
                `;
                return;
            }
            
            if (!response.ok) {
                throw new Error("Không thể kết nối tới Graph API.");
            }
            
            const data = await response.json();
            const recs = data.recommendations;
            const history = data.history || [];
            
            // Xóa loading
            loading.style.display = "none";

            // Cập nhật tên user trên tiêu đề kết quả
            targetUserSpan.innerText = data.username;
            
            // Lọc phía Client-side để đảm bảo tính nhất quán nếu mysqlBookTitles có dữ liệu
            const filteredHistory = history.filter(item => mysqlBookTitles.size === 0 || mysqlBookTitles.has(item.title.trim().toLowerCase()));
            const filteredRecs = recs.filter(rec => mysqlBookTitles.size === 0 || mysqlBookTitles.has(rec.title.trim().toLowerCase()));
            
            // 1. DỰNG LỊCH SỬ SÁCH ĐÃ ĐỌC
            historyGrid.innerHTML = "";
            if (filteredHistory.length === 0) {
                historyGrid.innerHTML = `
                    <div style="grid-column: 1/-1; text-align: center; padding: 2rem; color: var(--text-muted);">
                        Chưa có dữ liệu sách đã đọc (hoặc sách chưa có trong MySQL).
                    </div>
                `;
            } else {
                filteredHistory.forEach(item => {
                    const card = document.createElement("div");
                    card.classList.add("rec-card");
                    
                    // Xác định nhãn trạng thái tiếng Việt
                    let statusLabel = "Đã tương tác";
                    let statusClass = "";
                    if (item.status === "completed") {
                        statusLabel = "Đã hoàn thành";
                        statusClass = "completed";
                    } else if (item.status === "reading") {
                        statusLabel = "Đang đọc";
                        statusClass = "reading";
                    } else if (item.status === "interested") {
                        statusLabel = "Quan tâm";
                        statusClass = "interested";
                    }
                    
                    const ratingStars = item.rating > 0 ? "⭐".repeat(item.rating) : "Chưa đánh giá";
                    const readUrl = getReadUrl(item.title);
                    
                    card.innerHTML = `
                        <span class="card-category">${item.category}</span>
                        <h4 class="card-title"><a href="${readUrl}" target="_blank" class="book-link" title="Bấm vào để đọc sách">${item.title}</a></h4>
                        <div class="card-footer">
                            <span class="score-tag">Đánh giá: <span class="score-num" style="color: var(--warning);">${ratingStars}</span></span>
                            <span class="status-tag ${statusClass}">${statusLabel}</span>
                        </div>
                    `;
                    historyGrid.appendChild(card);
                });
            }

            // 2. DỰNG DANH SÁCH GỢI Ý
            if (filteredRecs.length === 0) {
                recGrid.innerHTML = `
                    <div style="grid-column: 1/-1; text-align: center; padding: 2rem; color: var(--text-muted);">
                        Không tìm thấy gợi ý nào phù hợp có sẵn trong MySQL.
                    </div>
                `;
            } else {
                recGrid.innerHTML = "";
                filteredRecs.forEach(rec => {
                    const card = document.createElement("div");
                    card.classList.add("rec-card");
                    
                    // Định nghĩa nhãn thuật toán và biểu tượng
                    let tagLabel = rec.type;
                    let tagClass = "";
                    let scoreLabel = "Mức độ gợi ý: ";
                    let scoreIcon = "🔥";
                    
                    if (rec.type === "Loc cong tac") {
                        tagLabel = "Người đọc tương tự";
                        tagClass = "";
                        scoreLabel = "Độ tương quan: ";
                        scoreIcon = "👥";
                    } else if (rec.type === "Sach lien quan") {
                        tagLabel = "Sách liên quan";
                        tagClass = "";
                        scoreLabel = "Mức độ liên quan: ";
                        scoreIcon = "📖";
                    } else if (rec.type === "Xem nhieu") {
                        tagLabel = "Xem nhiều nhất";
                        tagClass = "chung";
                        scoreLabel = "Đánh giá trung bình: ";
                        scoreIcon = "⭐";
                    }
                    
                    const readUrl = getReadUrl(rec.title);
                    card.innerHTML = `
                        <span class="card-category">${rec.category}</span>
                        <h4 class="card-title"><a href="${readUrl}" target="_blank" class="book-link" title="Bấm vào để đọc sách">${rec.title}</a></h4>
                        <div class="card-footer">
                            <span class="score-tag">${scoreIcon} ${scoreLabel}<span class="score-num">${rec.score}</span></span>
                            <span class="type-tag ${tagClass}">${tagLabel}</span>
                        </div>
                    `;
                    recGrid.appendChild(card);
                });
            }
            
            // Hiện wrapper kết quả
            resultsWrapper.style.display = "block";
            
        } catch (err) {
            console.error(err);
            loading.style.display = "none";
            recGrid.innerHTML = "";
            historyGrid.innerHTML = "";
            resultsWrapper.style.display = "block";
            targetUserSpan.innerText = username + " (Lỗi)";
            recGrid.innerHTML = `
                <div style="grid-column: 1/-1; text-align: center; padding: 2rem; color: var(--error);">
                    ⚠️ Lỗi: Không thể kết nối tới Graph API (Port 5000). Hãy kiểm tra xem server Python Flask đã được chạy chưa.
                </div>
            `;
        }
    });
}
