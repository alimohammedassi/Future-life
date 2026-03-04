# مستند متطلبات الـ Backend (Backend Requirements Document)

هذا المستند يحتوي على كل التفاصيل الخاصة بمدخلات ومخرجات التطبيق وهيكلة قاعدة البيانات المطلوبة لكي يعمل التطبيق بشكل صحيح وتتطابق مع الـ Data Models الموجودة داخل تطبيق Flutter.

---

## أولاً: الهيكل العام لردود الـ API (API Response Structure)

يُفضل أن يُرجع الـ Backend جميع البيانات مغلفة (Wrapped) في الهيكل التالي:

```json
{
  "success": true,
  "data": { ... },
  "message": "عملية ناجحة"
}
```

---

## ثانياً: الجداول المطلوبة (Database Schema / Models)

### 1. جدول المستخدمين (Users Table)

يحتوي على بيانات حساب المستخدم الأساسية.

- **`id`**: String / UUID (Primary Key)
- **`fullName`**: String (مطلوب)
- **`email`**: String (مطلوب، Unique)
- **`password`**: String (تُحفظ مشفرة Hash)
- **`avatar`**: String (اختياري، رابط للصورة الشخصية)
- **`createdAt`**: DateTime (وقت الإنشاء)
- **`lastLoginAt`**: DateTime (وقت آخر تسجيل دخول)
- **`refreshToken`**: String (اختياري)

### 2. نموذج المدخلات (Simulation Input Model)

هذه هي المتغيرات التي يرسلها التطبيق لبدء المحاكاة أو التي سيتم حفظها مع كل نتيجة.

- **`monthlyIncome`**: Double (الدخل الشهري)
- **`savingPercentage`**: Double (نسبة الادخار من 0.0 إلى 0.50)
- **`dailyStudyHours`**: Double (ساعات الدراسة اليومية من 0.0 إلى 10.0)
- **`workoutDaysPerWeek`**: Integer (أيام التمرين أسبوعياً من 0 إلى 7)
- **`currency`**: String (العملة: USD, EGP, SAR, AED, KWD, QAR)
- **`careerField`**: String (مجال العمل، مثلاً Technology)
- **`weeklySkillHours`**: Double (ساعات تطوير المهارات أسبوعياً)
- **`certsPerYear`**: Integer (عدد الشهادات أو الدورات سنوياً)
- **`socialMediaHours`**: Double (ساعات السوشيال ميديا وقت الفراغ)
- **`familyHours`**: Double (ساعات الجلوس مع العائلة)
- **`networkingHours`**: Double (ساعات بناء العلاقات)

### 3. جدول النتائج والمحاكاة (Simulation Results Table)

يحفظ نتائج المحاكاة لكل مستخدم. _يُنصح باستخدام قاعدة بيانات تدعم JSONB أو تخزين بعض الكائنات المعقدة مثل `yearlySnapshots` كـ JSON Strings_.

- **`id`**: String / UUID (Primary Key)
- **`userId`**: String (Foreign Key)
- **`name`**: String (اسم السيناريو)
- **`createdAt`**: DateTime (وقت الحفظ)
- **الحالة المالية (Financial):**
  - `savings1Y`, `savings5Y`, `savings10Y`: Double
  - `monthlySavings`: Double
  - `netWorth10Y`: Double
  - `currency`: String
- **المعرفة والدراسة (Knowledge):**
  - `studyHours1Y`, `studyHours5Y`, `studyHours10Y`: Double
- **الصحة (Health):**
  - `healthScore1Y`, `healthScore5Y`, `healthScore10Y`: Double
- **المسار المهني (Career):**
  - `careerGrowthIndex`: Double
  - `salaryMultiplier`: Double
  - `promotionProbability`: Double
- **الحياة الاجتماعية (Social):**
  - `socialBalanceScore`: Double
  - `isolationRisk`: Double
- **الطاقة والاستراتيجية (Energy & Strategy):**
  - `lifeStrategyScore`: Double
  - `energyScore1Y`, `energyScore5Y`, `energyScore10Y`: Double
  - `burnoutRisk`: Double
- **المخاطر (Risk):**
  - `financialCollapseRisk`: Double
  - `careerStagnationRisk`: Double
  - `energyDepletionRisk`: Double
  - `overallRiskIndex`: Double
- **بيانات الرسوم البيانية (Chart Data):**
  - `yearlySnapshots`: مصفوفة كائنات تحتوى مسار 10 سنوات (مفاتيح الكائن: `year`, `savings`, `studyHours`, `healthScore`).
  - `monthlySnapshots`: مصفوفة كائنات تحتوى مسار الشهور (مفاتيح الكائن: `month`, `savings`, `studyHours`, `healthScore`).

---

## ثالثاً: روابط الـ API المطلوبة (API Endpoints Requirement)

### 1. نظام المصادقة (Authentication)

- **إنشاء حساب (Register):**
  - **الرابط:** `POST /auth/register`
  - **المدخلات:** `{ "fullName": "...", "email": "...", "password": "..." }`
  - **المخرجات المتوقعة في `data`:** `{ "accessToken": "...", "refreshToken": "...", "user": { profile object } }`

- **تسجيل الدخول (Login):**
  - **الرابط:** `POST /auth/login`
  - **المدخلات:** `{ "email": "...", "password": "..." }`
  - **المخرجات المتوقعة في `data`:** `{ "accessToken": "...", "refreshToken": "...", "user": { profile object } }`

- **تحديث التوكن (Refresh Token):**
  - **الرابط:** `POST /auth/refresh`
  - **المدخلات:** `{ "refreshToken": "..." }`
  - **المخرجات المتوقعة في `data`:** `{ "accessToken": "..." }`

- **تسجيل الخروج (Logout):**
  - **الرابط:** `POST /auth/logout` (يتطلب `Authorization: Bearer token`)

### 2. حساب المستخدم (User Profile)

_(يتطلب إرسال `Authorization: Bearer token` في Header)_

- **جلب بيانات المستخدم (Get Profile):**
  - **الرابط:** `GET /auth/me`
- **تعديل بيانات المستخدم (Update Profile):**
  - **الرابط:** `PATCH /auth/profile`
  - **المدخلات:** `{ "fullName": "...", "email": "..." }`

### 3. المحاكاة (Simulation System)

_(يتطلب إرسال `Authorization: Bearer token` في Header)_

- **تشغيل محاكاة جديدة (Run Simulation):**
  - **الرابط:** `POST /api/simulation/run`
  - **المدخلات:** كائن `SimulationInput` كامل.
  - **المخرجات:** كائن `SimulationResult` كامل بالنتائج المتوقعة.

- **حفظ نتيجة المحاكاة في سجل المستخدم (Save Simulation):**
  - **الرابط:** `POST /api/simulation`
  - **المدخلات:** كائن `SimulationResult` الذي تم إنتاجه.

- **تشغيل السيناريوهات المتعددة المتوازية (Parallel Futures):**
  - **الرابط:** `POST /api/simulation/parallel-futures`
  - **المدخلات:** كائن `SimulationInput`.
  - **المخرجات في `data`:**
    ```json
    {
      "current": { SimulationResult Object },
      "optimized": { SimulationResult Object },
      "decline": { SimulationResult Object }
    }
    ```

- **جلب تاريخ المحاكيات السابقة للمستخدم (Get History):**
  - **الرابط:** `GET /api/simulation/history`
  - **المخرجات في `data`:** مصفوفة (Array) من كائنات `SimulationResult`.

- **جلب محاكاة معينة بالـ ID:**
  - **الرابط:** `GET /api/simulation/{id}`

- **حذف محاكاة (Delete Simulation):**
  - **الرابط:** `DELETE /api/simulation/{id}`

- **إحصائيات عامة للمستخدم (Stats):**
  - **الرابط:** `GET /api/simulation/stats`
  - **المخرجات في `data`:** كائن يحتوي على بيانات إحصائية (مثل عدد السيناريوهات المحفوظة، أعلى درجة تقييم، إلخ).
