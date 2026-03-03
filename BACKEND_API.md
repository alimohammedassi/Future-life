# Backend API Integration

This document describes the API endpoints that should be implemented on your backend at `http://mohammedsaead00-001-site1.rtempurl.com`.

## Base URL
```
http://mohammedsaead00-001-site1.rtempurl.com
```

## API Endpoints

### 1. Run Simulation
**POST** `/api/simulation/run`

Runs a life simulation based on user input.

**Request Body:**
```json
{
  "monthlyIncome": 4500.0,
  "savingPercentage": 0.25,
  "dailyStudyHours": 2.5,
  "workoutDaysPerWeek": 4,
  "currency": "USD",
  "careerField": "Technology",
  "weeklySkillHours": 5.0,
  "certsPerYear": 1,
  "socialMediaHours": 2.0,
  "familyHours": 10.0,
  "networkingHours": 2.0
}
```

**Response:**
```json
{
  "id": "uuid-string",
  "name": "Current Habits",
  "createdAt": "2026-03-02T23:00:00.000Z",
  "savings1Y": 13500.0,
  "savings5Y": 85000.0,
  "savings10Y": 180000.0,
  "monthlySavings": 1125.0,
  "netWorth10Y": 180000.0,
  "studyHours1Y": 912.5,
  "studyHours5Y": 4562.5,
  "studyHours10Y": 9125.0,
  "healthScore1Y": 75.0,
  "healthScore5Y": 82.0,
  "healthScore10Y": 85.0,
  "careerGrowthIndex": 1.25,
  "salaryMultiplier": 2.5,
  "promotionProbability": 0.75,
  "socialBalanceScore": 65.0,
  "isolationRisk": 0.25,
  "currency": "USD",
  "lifeStrategyScore": 78.0,
  "energyScore1Y": 70.0,
  "energyScore5Y": 75.0,
  "energyScore10Y": 72.0,
  "burnoutRisk": 0.15,
  "financialCollapseRisk": 0.05,
  "careerStagnationRisk": 0.20,
  "energyDepletionRisk": 0.10,
  "overallRiskIndex": 25.0,
  "yearlySnapshots": [...],
  "monthlySnapshots": [...]
}
```

### 2. Get Simulation History
**GET** `/api/simulation/history`

Retrieves user's simulation history.

**Response:**
```json
[
  {
    "id": "uuid-string-1",
    "name": "Current Habits",
    "createdAt": "2026-03-02T23:00:00.000Z",
    ...
  },
  {
    "id": "uuid-string-2", 
    "name": "Optimized Path",
    "createdAt": "2026-03-02T22:30:00.000Z",
    ...
  }
]
```

### 3. Save Simulation
**POST** `/api/simulation`

Saves a simulation result.

**Request Body:**
```json
{
  "id": "uuid-string",
  "name": "Current Habits", 
  "createdAt": "2026-03-02T23:00:00.000Z",
  ... // full simulation result object
}
```

**Response:**
```json
{
  "id": "uuid-string",
  "name": "Current Habits",
  "createdAt": "2026-03-02T23:00:00.000Z",
  ... // saved simulation result
}
```

### 4. Get Simulation by ID
**GET** `/api/simulation/{id}`

Retrieves a specific simulation by ID.

**Response:**
```json
{
  "id": "uuid-string",
  "name": "Current Habits",
  "createdAt": "2026-03-02T23:00:00.000Z",
  ... // full simulation result
}
```

### 5. Delete Simulation
**DELETE** `/api/simulation/{id}`

Deletes a specific simulation.

**Response:**
```
204 No Content
```

### 6. Get Simulation Statistics
**GET** `/api/simulation/stats`

Gets user simulation statistics.

**Response:**
```json
{
  "totalSimulations": 15,
  "averageLifeStrategyScore": 72.5,
  "mostUsedCurrency": "USD",
  "averageSavingPercentage": 0.28
}
```

### 7. Run Parallel Futures Simulation
**POST** `/api/simulation/parallel-futures`

Runs Current, Optimized, and Decline path simulations simultaneously.

**Request Body:**
```json
{
  "monthlyIncome": 4500.0,
  "savingPercentage": 0.25,
  "dailyStudyHours": 2.5,
  "workoutDaysPerWeek": 4,
  "currency": "USD",
  "careerField": "Technology",
  "weeklySkillHours": 5.0,
  "certsPerYear": 1,
  "socialMediaHours": 2.0,
  "familyHours": 10.0,
  "networkingHours": 2.0
}
```

**Response:**
```json
{
  "current": {
    "id": "current-uuid",
    "name": "Current Path",
    ... // full simulation result
  },
  "optimized": {
    "id": "optimized-uuid", 
    "name": "Optimized Path",
    ... // full simulation result
  },
  "decline": {
    "id": "decline-uuid",
    "name": "Decline Path",
    ... // full simulation result
  }
}
```

## Error Handling

The API uses standard HTTP status codes:

- `200` - Success
- `201` - Created
- `204` - No Content (successful deletion)
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error

Error responses follow this format:
```json
{
  "message": "Error description",
  "statusCode": 400
}
```

## Implementation Notes

1. The Flutter app will automatically handle network failures by falling back to local simulation
2. All data is sent as JSON
3. Timestamps should be in ISO 8601 format
4. UUIDs should be generated server-side for consistency
5. The app expects the same field structure as defined in the Flutter models