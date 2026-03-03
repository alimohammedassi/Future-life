# 📚 FutureLife API Documentation (For Frontend)

هذا المستند يحتوي على كل ما يحتاجه مطور الـ Frontend (Web/Mobile) لربط التطبيق مع الـ Backend بنجاح.

---

## 🔗 1. Base URL
يجب استبدال `YOUR_API_URL` برابط السيرفر الفعلي المرفوع على SmarterASP.NET. حطه في متغير عام في التطبيق.
```javascript
const BASE_URL = "http://YOUR_API_URL.com";
```

## 🛡️ 2. Authentication (المصادقة)
الـ API بيستخدم JWT (JSON Web Tokens).
- أي Endpoint مكتوب جنبه **(Protected)** معناه إنه لازم تبعت الـ Token في הـ Header بتاع الطلب كالتالي:
```http
Authorization: Bearer <YOUR_TOKEN_HERE>
```

## 📦 3. Response Format (الهيكل الموحد للردود)
كل الردود من الـ API (سواء نجاح أو فشل) بتمشي على الهيكل ده:
```json
{
  "success": true, // أو false في حالة الخطأ
  "data": { ... }, // الداتا المطلوبة (ممكن تكون null)
  "message": "Success message" // أو رسالة الخطأ
}
```

---

## 🌐 4. Endpoints List

### 🔓 1. Auth (المصادقة)

#### 1.1 تسجييل حساب جديد
- **URL**: `POST /auth/register`
- **Body**:
```json
{
  "fullName": "Mohamed",
  "email": "mohamed@test.com",
  "password": "strongpassword123",
  "preferredCurrency": "EGP" // اختياري، الـ default هو USD
}
```
- **Response**: بيرجع `token` وبيانات الـ user.

#### 1.2 تسجيل الدخول
- **URL**: `POST /auth/login`
- **Body**:
```json
{
  "email": "mohamed@test.com",
  "password": "strongpassword123"
}
```
- **Response**: بيرجع `token` (احفظه عندك) وبيانات الـ user.

#### 1.3 جلب بيانات المستخدم الحالي 🔒(Protected)
- **URL**: `GET /auth/me`
- **Response**: بيرجع بيانات الـ user (بدون الباسورد طبعاً).

---

### 🔓 2. Users (إدارة المستخدم)

#### 2.1 تعديل بيانات المستخدم 🔒(Protected)
- **URL**: `PUT /users/me`
- **Body**:
```json
{
  "fullName": "Mohamed Ali", // اختياري
  "preferredCurrency": "SAR"  // اختياري
}
```

---

### 🔓 3. Exchange Rates (العملات)

#### 3.1 جلب أسعار العملات
- **URL**: `GET /exchange-rates`
- **Response**: بيرجع Array بكل العملات المتاحة وسعرها مقابل الدولار.
```json
"data": [
  { "id": 1, "currencyCode": "USD", "rateToUsd": 1, "updatedAt": "..." },
  { "id": 2, "currencyCode": "EGP", "rateToUsd": 0.0204, "updatedAt": "..." }
]
```

---

### 🔓 4. Profiles (البروفايلات أو خطط الحياة)

#### 4.1 إنشاء بروفايل جديد 🔒(Protected)
- **URL**: `POST /profiles`
- **Body**: (كل الحقول دي مطلوبة ما عدا *gender*, *country*, *jobTitle* فهي اختيارية)
```json
{
  "name": "My Dream Life",
  "age": 28,
  "gender": "Male",
  "country": "Egypt",
  "currentSavings": 50000,
  "monthlyIncome": 15000,
  "monthlyExpenses": 8000,
  "investmentReturnRate": 0.07,
  "inflationRate": 0.03,
  "currency": "EGP",
  "currentSalary": 15000,
  "annualSalaryGrowthRate": 0.05,
  "promotionProbability": 0.15,
  "promotionSalaryBoost": 0.20,
  "jobTitle": "Software Engineer",
  "sleepHoursPerNight": 7,
  "exerciseDaysPerWeek": 3,
  "stressLevel": 6,
  "bmi": 24.5,
  "socialInteractionsPerWeek": 5,
  "closeFriendsCount": 4,
  "communityEngagementScore": 6
}
```
- **Response**: بيرجع بيانات البروفايل كاملة ومعاها `id` (مهم جداً للأسئلة الجاية).

#### 4.2 جلب كل بروفايلات المستخدم 🔒(Protected)
- **URL**: `GET /profiles`
- **Response**: بيرجع Array من البروفايلات.

#### 4.3 جلب بروفايل محدد 🔒(Protected)
- **URL**: `GET /profiles/{id}`

#### 4.4 تعديل بروفايل 🔒(Protected)
- **URL**: `PUT /profiles/{id}`
- **Body**: نفس הـ Body بتاع الإنشاء بالظبط.

#### 4.5 حذف بروفايل 🔒(Protected)
- **URL**: `DELETE /profiles/{id}`

---

### 🔓 5. Simulation (المحاكاة - أهم جزء) 🔥

#### 5.1 تشغيل محاكاة جديدة لبروفايل 🔒(Protected)
- **URL**: `POST /profiles/{profileId}/simulate`
- **Body**:
```json
{
  "projectionYears": 10, // عدد سنين المحاكاة (من 1 لـ 50)
  "currency": "SAR"      // اختياري، لو مبعتوش هيستخدم عملة البروفايل
}
```
- **Response**: بيرجع كائن (Object) ضخم تفصيلي بيحتوي على 4 أقسام رئيسية: `Finance`, `Career`, `Health`, `Social`. كل قسم جواه ملخص + `YearlyBreakdown` (تفصيل سنة بسنة عشان ترسمه في Charts).

#### 5.2 جلب نتايج المحاكاة السابقة (History) 🔒(Protected)
- **URL**: `GET /profiles/{profileId}/results`
- **Response**: بيرجع Array بكل المحاكيات اللي اتعملت للبروفايل ده قبل كدا بالنتيجة كاملة لكل واحدة.
