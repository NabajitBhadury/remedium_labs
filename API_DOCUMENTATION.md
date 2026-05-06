# Lab Test Booking App — API Documentation

> **Base URL:** `https://api.labtest.example.com/v1`
>
> **Note:** The current implementation uses a local `MockDataService` (in `lib/services/mock_data_service.dart`) to simulate all network calls. This document describes the **intended REST API contract** that the app is designed around. All request/response shapes are derived from the Flutter data models.

---

## Table of Contents

1. [Authentication](#1-authentication)
   - [POST /auth/login](#post-authlogin)
   - [POST /auth/register](#post-authregister)
   - [POST /auth/logout](#post-authlogout)
2. [Banners](#2-banners)
   - [GET /banners](#get-banners)
3. [Organs](#3-organs)
   - [GET /organs](#get-organs)
4. [Diseases](#4-diseases)
   - [GET /diseases](#get-diseases)
5. [Services (Lab Tests)](#5-services-lab-tests)
   - [GET /services/popular](#get-servicespopular)
   - [GET /services/by-organ/:organName](#get-servicesby-organorganname)
   - [GET /services/by-disease/:diseaseName](#get-servicesby-diseasediseasename)
   - [GET /services/:id](#get-servicesid)
6. [Labs](#6-labs)
   - [GET /labs](#get-labs)
   - [GET /labs/:id](#get-labsid)
   - [GET /labs/by-service/:serviceId](#get-labsby-serviceserviceid)
7. [Bookings](#7-bookings)
   - [GET /bookings](#get-bookings)
   - [POST /bookings](#post-bookings)
   - [GET /bookings/:id](#get-bookingsid)
   - [PATCH /bookings/:id/cancel](#patch-bookingsidcancel)
8. [Family Members](#8-family-members)
   - [GET /users/me/family-members](#get-usersme-family-members)
   - [POST /users/me/family-members](#post-usersme-family-members)
   - [DELETE /users/me/family-members/:id](#delete-usersme-family-membersid)
9. [Payments](#9-payments)
   - [GET /payments](#get-payments)
   - [POST /payments/initiate](#post-paymentsinitiate)
   - [GET /payments/:id](#get-paymentsid)
10. [User Profile](#10-user-profile)
    - [GET /users/me](#get-usersme)
    - [PATCH /users/me](#patch-usersme)

---

## Common Conventions

### Authentication
All protected routes require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

### Response Envelope
All responses follow this structure:

```json
{
  "success": true,
  "data": { ... },
  "message": "OK"
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error description"
  }
}
```

### HTTP Status Codes

| Code | Meaning                  |
|------|--------------------------|
| 200  | OK                       |
| 201  | Created                  |
| 400  | Bad Request              |
| 401  | Unauthorized             |
| 403  | Forbidden                |
| 404  | Not Found                |
| 422  | Unprocessable Entity     |
| 500  | Internal Server Error    |

---

## 1. Authentication

### POST /auth/login

Authenticates a user with phone number and password. Returns an access token and user profile on success.

**Auth Required:** ❌ No

**Request Body:**

```json
{
  "phone": "9876543210",
  "password": "yourPassword123"
}
```

| Field    | Type   | Required | Description                    |
|----------|--------|----------|--------------------------------|
| phone    | string | ✅ Yes   | Registered mobile phone number |
| password | string | ✅ Yes   | User's account password        |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "u1",
      "name": "Test User",
      "phone": "9876543210"
    }
  },
  "message": "Login successful"
}
```

**Error Response `401 Unauthorized`:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Phone number or password is incorrect"
  }
}
```

---

### POST /auth/register

Creates a new user account.

**Auth Required:** ❌ No

**Request Body:**

```json
{
  "name": "John Doe",
  "phone": "9876543210",
  "password": "securePassword123"
}
```

| Field    | Type   | Required | Description              |
|----------|--------|----------|--------------------------|
| name     | string | ✅ Yes   | Full name of the user    |
| phone    | string | ✅ Yes   | Mobile phone number      |
| password | string | ✅ Yes   | Minimum 8-character password |

**Success Response `201 Created`:**

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "u2",
      "name": "John Doe",
      "phone": "9876543210"
    }
  },
  "message": "Registration successful"
}
```

**Error Response `422 Unprocessable Entity`:**

```json
{
  "success": false,
  "error": {
    "code": "PHONE_ALREADY_REGISTERED",
    "message": "An account with this phone number already exists"
  }
}
```

---

### POST /auth/logout

Invalidates the current user session and access token.

**Auth Required:** ✅ Yes

**Request Body:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": null,
  "message": "Logged out successfully"
}
```

---

## 2. Banners

### GET /banners

Returns a list of promotional banners to display on the home screen carousel.

**Auth Required:** ❌ No

**Query Parameters:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "banner_1",
      "title": "Full Body Checkup",
      "subtitle": "Get 20% Off today!",
      "button_text": "Book Now",
      "image_url": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=500",
      "gradient_start_color": "#10217D",
      "gradient_end_color": "#1557B0",
      "button_color": "#FFFFFF",
      "button_text_color": "#10217D"
    },
    {
      "id": "banner_2",
      "title": "Health Package",
      "subtitle": "Comprehensive health check",
      "button_text": "Learn More",
      "image_url": "https://images.unsplash.com/photo-1579154204601-01588f351e67?auto=format&fit=crop&q=80&w=500",
      "gradient_start_color": "#FF9431",
      "gradient_end_color": "#FF8C00",
      "button_color": "#FFFFFF",
      "button_text_color": "#FF9431"
    }
  ],
  "message": "OK"
}
```

**BannerModel Fields:**

| Field               | Type   | Description                              |
|---------------------|--------|------------------------------------------|
| id                  | string | Unique banner identifier                 |
| title               | string | Primary headline text                    |
| subtitle            | string | Supporting text                          |
| button_text         | string | CTA button label                         |
| image_url           | string | URL of the banner image                  |
| gradient_start_color | string | Hex color for gradient start            |
| gradient_end_color  | string | Hex color for gradient end               |
| button_color        | string | Hex color for the CTA button background  |
| button_text_color   | string | Hex color for the CTA button text        |

---

## 3. Organs

### GET /organs

Returns the list of organ categories used for filtering lab tests.

**Auth Required:** ❌ No

**Query Parameters:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "org_1",
      "name": "Heart",
      "icon_key": "heart_pulse",
      "color": "#F44336"
    },
    {
      "id": "org_2",
      "name": "Kidney",
      "icon_key": "tablets",
      "color": "#FF9800"
    },
    {
      "id": "org_3",
      "name": "Liver",
      "icon_key": "wine_bottle",
      "color": "#795548"
    },
    {
      "id": "org_4",
      "name": "Lungs",
      "icon_key": "lungs",
      "color": "#2196F3"
    },
    {
      "id": "org_5",
      "name": "Brain",
      "icon_key": "brain",
      "color": "#E91E63"
    },
    {
      "id": "org_6",
      "name": "Stomach",
      "icon_key": "burger",
      "color": "#4CAF50"
    }
  ],
  "message": "OK"
}
```

**Organ Fields:**

| Field    | Type   | Description                                        |
|----------|--------|----------------------------------------------------|
| id       | string | Unique organ identifier                            |
| name     | string | Display name of the organ                          |
| icon_key | string | Key mapping to a client-side icon (FontAwesome)    |
| color    | string | Hex color used for the icon and accent             |

---

## 4. Diseases

### GET /diseases

Returns a list of disease categories used to filter relevant lab tests.

**Auth Required:** ❌ No

**Query Parameters:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "dis_1",
      "name": "Fever",
      "icon_key": "temperature_high",
      "color": "#F44336"
    },
    {
      "id": "dis_2",
      "name": "Covid-19",
      "icon_key": "virus",
      "color": "#9C27B0"
    },
    {
      "id": "dis_3",
      "name": "Diabetes",
      "icon_key": "syringe",
      "color": "#2196F3"
    },
    {
      "id": "dis_4",
      "name": "Heart",
      "icon_key": "heart_pulse",
      "color": "#EF5350"
    },
    {
      "id": "dis_5",
      "name": "Kidney",
      "icon_key": "tablets",
      "color": "#FF9800"
    }
  ],
  "message": "OK"
}
```

**Disease Fields:**

| Field    | Type   | Description                                     |
|----------|--------|-------------------------------------------------|
| id       | string | Unique disease identifier                       |
| name     | string | Human-readable disease name                     |
| icon_key | string | Key mapping to a client-side icon (FontAwesome) |
| color    | string | Hex display color for the icon                  |

---

## 5. Services (Lab Tests)

### GET /services/popular

Returns the list of most popular lab test services shown on the home screen.

**Auth Required:** ❌ No

**Query Parameters:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Complete Blood Count (CBC)",
      "price": 50.0,
      "duration_minutes": 15,
      "description": "Measures different parts of the blood. Vital for overall health."
    },
    {
      "id": "2",
      "name": "Thyroid Profile",
      "price": 80.0,
      "duration_minutes": 20,
      "description": "Checks thyroid function and hormone levels."
    },
    {
      "id": "3",
      "name": "Liver Function Test",
      "price": 70.0,
      "duration_minutes": 20,
      "description": "Screening for liver damage and enzymes."
    },
    {
      "id": "4",
      "name": "Lipid Profile",
      "price": 60.0,
      "duration_minutes": 15,
      "description": "Cholesterol and triglycerides check. Important for heart health."
    },
    {
      "id": "5",
      "name": "Kidney Function Test",
      "price": 90.0,
      "duration_minutes": 20,
      "description": "Check kidney health and creatinine levels."
    }
  ],
  "message": "OK"
}
```

---

### GET /services/by-organ/:organName

Returns all lab tests associated with a specific organ category.

**Auth Required:** ❌ No

**Path Parameters:**

| Parameter | Type   | Description                             |
|-----------|--------|-----------------------------------------|
| organName | string | Name of the organ (e.g., `Heart`)       |

**Example Request:** `GET /services/by-organ/Heart`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Complete Blood Count (CBC)",
      "price": 50.0,
      "duration_minutes": 15,
      "description": "Measures different parts of the blood. Vital for overall health."
    },
    {
      "id": "4",
      "name": "Lipid Profile",
      "price": 60.0,
      "duration_minutes": 15,
      "description": "Cholesterol and triglycerides check."
    }
  ],
  "message": "OK"
}
```

**Error Response `404 Not Found`:**

```json
{
  "success": false,
  "error": {
    "code": "ORGAN_NOT_FOUND",
    "message": "No organ found with name 'Pancreas'"
  }
}
```

---

### GET /services/by-disease/:diseaseName

Returns all lab tests relevant to a specific disease category.

**Auth Required:** ❌ No

**Path Parameters:**

| Parameter   | Type   | Description                                |
|-------------|--------|--------------------------------------------|
| diseaseName | string | Name of the disease (e.g., `Diabetes`)     |

**Example Request:** `GET /services/by-disease/Diabetes`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "2",
      "name": "Thyroid Profile",
      "price": 80.0,
      "duration_minutes": 20,
      "description": "Checks thyroid function and hormone levels."
    },
    {
      "id": "5",
      "name": "Kidney Function Test",
      "price": 90.0,
      "duration_minutes": 20,
      "description": "Check kidney health and creatinine levels."
    }
  ],
  "message": "OK"
}
```

---

### GET /services/:id

Returns detailed information for a single service.

**Auth Required:** ❌ No

**Path Parameters:**

| Parameter | Type   | Description              |
|-----------|--------|--------------------------|
| id        | string | Unique service identifier |

**Example Request:** `GET /services/1`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "1",
    "name": "Complete Blood Count (CBC)",
    "price": 50.0,
    "duration_minutes": 15,
    "description": "Measures different parts of the blood. Vital for overall health."
  },
  "message": "OK"
}
```

**Service Model Fields:**

| Field            | Type   | Description                            |
|------------------|--------|----------------------------------------|
| id               | string | Unique service identifier              |
| name             | string | Name of the lab test                   |
| price            | number | Price in INR (₹)                       |
| duration_minutes | integer| Estimated time to complete the test    |
| description      | string | Short description of what is measured  |

---

## 6. Labs

### GET /labs

Returns all available diagnostic labs. Supports optional filtering by service availability.

**Auth Required:** ❌ No

**Query Parameters:**

| Parameter  | Type   | Required | Description                                  |
|------------|--------|----------|----------------------------------------------|
| service_id | string | ❌ No    | Filter labs offering a specific service       |
| lat        | number | ❌ No    | User latitude for distance-based sorting      |
| lng        | number | ❌ No    | User longitude for distance-based sorting     |

**Example Request:** `GET /labs`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "l1",
      "name": "City Health Lab",
      "address": "123 Main St, New York, NY",
      "distance": 2.5,
      "rating": 4.8,
      "image_url": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=1000",
      "services": [
        {
          "id": "1",
          "name": "Complete Blood Count (CBC)",
          "price": 50.0,
          "duration_minutes": 15,
          "description": "Measures different parts of the blood."
        }
      ]
    },
    {
      "id": "l2",
      "name": "Advanced Diagnostics",
      "address": "456 Elm Ave, Brooklyn, NY",
      "distance": 4.1,
      "rating": 4.5,
      "image_url": "https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=1000",
      "services": []
    }
  ],
  "message": "OK"
}
```

**Lab Model Fields:**

| Field     | Type           | Description                                 |
|-----------|----------------|---------------------------------------------|
| id        | string         | Unique lab identifier                       |
| name      | string         | Name of the diagnostic lab                  |
| address   | string         | Full street address                         |
| distance  | number         | Distance in km from the user's location     |
| rating    | number         | Average star rating (1.0 – 5.0)             |
| image_url | string         | URL to the lab's cover image                |
| services  | Service[]      | List of services offered by this lab        |

---

### GET /labs/:id

Returns detailed information for a single lab, including all available services.

**Auth Required:** ❌ No

**Path Parameters:**

| Parameter | Type   | Description           |
|-----------|--------|-----------------------|
| id        | string | Unique lab identifier |

**Example Request:** `GET /labs/l1`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "l1",
    "name": "City Health Lab",
    "address": "123 Main St, New York, NY",
    "distance": 2.5,
    "rating": 4.8,
    "image_url": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d",
    "services": [
      {
        "id": "1",
        "name": "Complete Blood Count (CBC)",
        "price": 50.0,
        "duration_minutes": 15,
        "description": "Measures different parts of the blood."
      }
    ]
  },
  "message": "OK"
}
```

**Error Response `404 Not Found`:**

```json
{
  "success": false,
  "error": {
    "code": "LAB_NOT_FOUND",
    "message": "No lab found with ID 'l99'"
  }
}
```

---

### GET /labs/by-service/:serviceId

Returns all labs that offer a specific lab test service. This is used in the `LabsForServiceScreen`.

**Auth Required:** ❌ No

**Path Parameters:**

| Parameter | Type   | Description                      |
|-----------|--------|----------------------------------|
| serviceId | string | The service/test ID to filter by |

**Example Request:** `GET /labs/by-service/1`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "l1",
      "name": "City Health Lab",
      "address": "123 Main St, New York, NY",
      "distance": 2.5,
      "rating": 4.8,
      "image_url": "https://images.unsplash.com/...",
      "services": []
    },
    {
      "id": "l4",
      "name": "Prime Diagnostic Centre",
      "address": "321 Pine St, Bronx, NY",
      "distance": 8.2,
      "rating": 4.6,
      "image_url": "https://images.unsplash.com/...",
      "services": []
    }
  ],
  "message": "OK"
}
```

---

## 7. Bookings

### GET /bookings

Returns the authenticated user's appointment booking history.

**Auth Required:** ✅ Yes

**Query Parameters:**

| Parameter | Type   | Required | Description                                           |
|-----------|--------|----------|-------------------------------------------------------|
| status    | string | ❌ No    | Filter by status: `pending`, `confirmed`, `completed`, `cancelled` |

**Example Request:** `GET /bookings`

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "b1",
      "lab_name": "City Health Lab",
      "service_name": "Complete Blood Count (CBC)",
      "date": "2024-03-01",
      "time": "10:00",
      "status": "completed",
      "patient_name": "John Doe",
      "visit_type": "Lab Visit",
      "address": null
    },
    {
      "id": "b2",
      "lab_name": "Advanced Diagnostics",
      "service_name": "Lipid Profile",
      "date": "2024-03-04",
      "time": "14:30",
      "status": "confirmed",
      "patient_name": "John Doe",
      "visit_type": "Home Collection",
      "address": "456 Park Ave, New York"
    }
  ],
  "message": "OK"
}
```

**Booking Model Fields:**

| Field        | Type   | Description                                                         |
|--------------|--------|---------------------------------------------------------------------|
| id           | string | Unique booking identifier                                           |
| lab_name     | string | Name of the diagnostic lab                                          |
| service_name | string | Name of the test booked                                             |
| date         | string | Appointment date in `YYYY-MM-DD` format                             |
| time         | string | Appointment time in `HH:mm` (24h) format                           |
| status       | string | One of: `pending`, `confirmed`, `completed`, `cancelled`           |
| patient_name | string | Name of the patient (self or family member)                         |
| visit_type   | string | `Lab Visit` or `Home Collection`                                    |
| address      | string | Home address for home collection (null for lab visits)              |

---

### POST /bookings

Creates a new appointment booking. This is triggered when the user completes the 4-step booking flow and confirms payment.

**Auth Required:** ✅ Yes

**Request Body:**

```json
{
  "lab_id": "l1",
  "service_id": "1",
  "patient_name": "John Doe",
  "patient_phone": "9876543210",
  "patient_gender": "Male",
  "date": "2024-03-10",
  "time": "10:00",
  "visit_type": "Lab Visit",
  "address": null,
  "booking_for": "Self"
}
```

| Field          | Type   | Required | Description                                          |
|----------------|--------|----------|------------------------------------------------------|
| lab_id         | string | ✅ Yes   | ID of the selected lab                               |
| service_id     | string | ✅ Yes   | ID of the selected test/service                      |
| patient_name   | string | ✅ Yes   | Full name of the patient                             |
| patient_phone  | string | ✅ Yes   | 10-digit contact number                              |
| patient_gender | string | ✅ Yes   | `Male`, `Female`, or `Other`                         |
| date           | string | ✅ Yes   | Appointment date in `YYYY-MM-DD` format              |
| time           | string | ✅ Yes   | Appointment time in `HH:mm` (24h) format             |
| visit_type     | string | ✅ Yes   | `Lab Visit` or `Home Collection`                     |
| address        | string | ❌ No    | Required if `visit_type` is `Home Collection`        |
| booking_for    | string | ✅ Yes   | `Self` or `Family`                                   |

**Success Response `201 Created`:**

```json
{
  "success": true,
  "data": {
    "id": "b3",
    "lab_name": "City Health Lab",
    "service_name": "Complete Blood Count (CBC)",
    "date": "2024-03-10",
    "time": "10:00",
    "status": "pending",
    "patient_name": "John Doe",
    "visit_type": "Lab Visit",
    "address": null
  },
  "message": "Booking requested successfully! Admin will confirm shortly."
}
```

**Error Response `422 Unprocessable Entity`:**

```json
{
  "success": false,
  "error": {
    "code": "SLOT_UNAVAILABLE",
    "message": "The selected time slot is no longer available"
  }
}
```

**Home Collection Distance Error `422`:**

```json
{
  "success": false,
  "error": {
    "code": "OUT_OF_RANGE",
    "message": "Sorry, this location is more than 10km away."
  }
}
```

---

### GET /bookings/:id

Returns detailed information for a single booking.

**Auth Required:** ✅ Yes

**Path Parameters:**

| Parameter | Type   | Description               |
|-----------|--------|---------------------------|
| id        | string | Unique booking identifier |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "b1",
    "lab_name": "City Health Lab",
    "service_name": "Complete Blood Count (CBC)",
    "date": "2024-03-01",
    "time": "10:00",
    "status": "completed",
    "patient_name": "John Doe",
    "visit_type": "Lab Visit",
    "address": null
  },
  "message": "OK"
}
```

---

### PATCH /bookings/:id/cancel

Cancels a pending or confirmed booking.

**Auth Required:** ✅ Yes

**Path Parameters:**

| Parameter | Type   | Description               |
|-----------|--------|---------------------------|
| id        | string | Unique booking identifier |

**Request Body:** None

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "b2",
    "status": "cancelled"
  },
  "message": "Booking cancelled successfully"
}
```

**Error Response `400 Bad Request`:**

```json
{
  "success": false,
  "error": {
    "code": "CANNOT_CANCEL",
    "message": "Completed or already cancelled bookings cannot be cancelled"
  }
}
```

---

## 8. Family Members

### GET /users/me/family-members

Returns all family members linked to the authenticated user's account.

**Auth Required:** ✅ Yes

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Jane Doe",
      "relation": "Spouse",
      "phone": "9876543210",
      "gender": "Female",
      "age": "28"
    }
  ],
  "message": "OK"
}
```

**FamilyMember Fields:**

| Field    | Type   | Description                                                     |
|----------|--------|-----------------------------------------------------------------|
| id       | string | Unique family member identifier                                 |
| name     | string | Full name of the family member                                  |
| relation | string | Relationship: `Mother`, `Father`, `Spouse`, `Child`, or `Other`|
| phone    | string | Contact number                                                  |
| gender   | string | `Male`, `Female`, or `Other`                                    |
| age      | string | Age of the family member                                        |

---

### POST /users/me/family-members

Adds a new family member to the authenticated user's profile.

**Auth Required:** ✅ Yes

**Request Body:**

```json
{
  "name": "Robert Doe",
  "relation": "Father",
  "phone": "9123456780",
  "gender": "Male",
  "age": "58"
}
```

| Field    | Type   | Required | Description                                                     |
|----------|--------|----------|-----------------------------------------------------------------|
| name     | string | ✅ Yes   | Full name of the family member                                  |
| relation | string | ✅ Yes   | `Mother`, `Father`, `Spouse`, `Child`, or `Other`               |
| phone    | string | ✅ Yes   | Contact number                                                  |
| gender   | string | ✅ Yes   | `Male`, `Female`, or `Other`                                    |
| age      | string | ✅ Yes   | Age of the family member                                        |

**Success Response `201 Created`:**

```json
{
  "success": true,
  "data": {
    "id": "2",
    "name": "Robert Doe",
    "relation": "Father",
    "phone": "9123456780",
    "gender": "Male",
    "age": "58"
  },
  "message": "Family member added successfully"
}
```

---

### DELETE /users/me/family-members/:id

Removes a family member from the authenticated user's profile.

**Auth Required:** ✅ Yes

**Path Parameters:**

| Parameter | Type   | Description                          |
|-----------|--------|--------------------------------------|
| id        | string | Unique family member identifier      |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": null,
  "message": "Family member removed successfully"
}
```

**Error Response `404 Not Found`:**

```json
{
  "success": false,
  "error": {
    "code": "MEMBER_NOT_FOUND",
    "message": "No family member found with ID '99'"
  }
}
```

---

## 9. Payments

### GET /payments

Returns the authenticated user's payment transaction history.

**Auth Required:** ✅ Yes

**Query Parameters:**

| Parameter | Type   | Required | Description                               |
|-----------|--------|----------|-------------------------------------------|
| status    | string | ❌ No    | Filter: `Success` or `Failed`             |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "total_spent": 170.0,
    "transactions": [
      {
        "id": "pay_1",
        "title": "Thyroid Profile",
        "lab": "City Lab",
        "date": "Oct 24, 2023",
        "amount": 50.0,
        "status": "Success",
        "booking_id": "b1"
      },
      {
        "id": "pay_2",
        "title": "Lipid Profile",
        "lab": "Health Plus",
        "date": "Sep 12, 2023",
        "amount": 60.0,
        "status": "Success",
        "booking_id": "b2"
      },
      {
        "id": "pay_3",
        "title": "Full Body Checkup",
        "lab": "MediCare",
        "date": "Aug 05, 2023",
        "amount": 120.0,
        "status": "Failed",
        "booking_id": "b3"
      }
    ]
  },
  "message": "OK"
}
```

**Transaction Fields:**

| Field      | Type   | Description                           |
|------------|--------|---------------------------------------|
| id         | string | Unique payment transaction ID         |
| title      | string | Name of the lab test paid for         |
| lab        | string | Lab name where the test was conducted |
| date       | string | Human-readable transaction date       |
| amount     | number | Amount paid in INR (₹)                |
| status     | string | `Success` or `Failed`                 |
| booking_id | string | Associated booking ID                 |

---

### POST /payments/initiate

Initiates a payment after the user confirms a booking. Triggers an OTP-based verification flow.

**Auth Required:** ✅ Yes

**Request Body:**

```json
{
  "booking_id": "b3",
  "amount": 50.0,
  "payment_method": "UPI"
}
```

| Field          | Type   | Required | Description                                     |
|----------------|--------|----------|-------------------------------------------------|
| booking_id     | string | ✅ Yes   | The booking this payment is for                 |
| amount         | number | ✅ Yes   | Payment amount in INR — service price + ₹10 if Home Collection |
| payment_method | string | ✅ Yes   | e.g., `UPI`, `Card`, `Net Banking`             |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "payment_id": "pay_new_1",
    "otp_sent": true,
    "masked_phone": "******3210"
  },
  "message": "OTP sent for payment verification"
}
```

---

### GET /payments/:id

Returns details of a specific payment transaction.

**Auth Required:** ✅ Yes

**Path Parameters:**

| Parameter | Type   | Description                 |
|-----------|--------|-----------------------------|
| id        | string | Unique payment transaction ID |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "pay_1",
    "title": "Thyroid Profile",
    "lab": "City Lab",
    "date": "Oct 24, 2023",
    "amount": 50.0,
    "status": "Success",
    "booking_id": "b1"
  },
  "message": "OK"
}
```

---

## 10. User Profile

### GET /users/me

Returns the authenticated user's profile information.

**Auth Required:** ✅ Yes

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "u1",
    "name": "Test User",
    "phone": "9876543210",
    "family_members_count": 1
  },
  "message": "OK"
}
```

---

### PATCH /users/me

Updates the authenticated user's name or phone number.

**Auth Required:** ✅ Yes

**Request Body:**

```json
{
  "name": "John Doe Updated",
  "phone": "9000000001"
}
```

| Field | Type   | Required | Description               |
|-------|--------|----------|---------------------------|
| name  | string | ❌ No    | Updated full name          |
| phone | string | ❌ No    | Updated phone number       |

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "id": "u1",
    "name": "John Doe Updated",
    "phone": "9000000001"
  },
  "message": "Profile updated successfully"
}
```

---

## Appendix — Booking Status Lifecycle

```
[POST /bookings]
      │
      ▼
   pending
      │
      ├── Admin confirms ──► confirmed
      │                           │
      │                           ├── Test done ──► completed
      │                           │
      │                           └── User cancels ──► cancelled
      │
      └── User cancels ──► cancelled
```

## Appendix — Home Collection Pricing

When the user selects **Home Collection** as the visit type, an additional ₹10 surcharge is added to the service price:

```
Total Amount = Service Price + ₹10 (Home Collection fee)
```

This is enforced both in the UI (booking review step) and should be validated server-side during payment initiation.

## Appendix — Available Time Slots

The booking flow currently offers the following fixed appointment slots:

| Slot | Time       |
|------|------------|
| 1    | 8:00 AM    |
| 2    | 9:00 AM    |
| 3    | 10:00 AM   |
| 4    | 11:00 AM   |
| 5    | 2:00 PM    |
| 6    | 4:00 PM    |
| 7    | 5:00 PM    |

Appointments can be booked up to **30 days** in advance.

---

*Last updated: March 2026 — Based on `MockDataService` in `lib/services/mock_data_service.dart`*
