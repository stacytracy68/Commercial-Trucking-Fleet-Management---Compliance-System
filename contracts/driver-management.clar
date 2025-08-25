;; Driver Management Contract
;; Handles driver registration, HOS compliance, and performance tracking

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-DRIVER-NOT-FOUND (err u101))
(define-constant ERR-INVALID-INPUT (err u102))
(define-constant ERR-HOS-VIOLATION (err u103))
(define-constant ERR-ALREADY-EXISTS (err u104))

;; Maximum hours per day and week for HOS compliance
(define-constant MAX-DAILY-HOURS u11)
(define-constant MAX-WEEKLY-HOURS u70)

;; Data Variables
(define-data-var next-driver-id uint u1)

;; Data Maps
(define-map drivers
  { driver-id: uint }
  {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    license-expiry: uint,
    cdl-class: (string-ascii 10),
    hire-date: uint,
    status: (string-ascii 20),
    safety-score: uint,
    total-violations: uint
  }
)

(define-map driver-hours
  { driver-id: uint, date: uint }
  {
    hours-worked: uint,
    break-time: uint,
    overtime-hours: uint,
    is-compliant: bool
  }
)

(define-map weekly-hours
  { driver-id: uint, week-start: uint }
  {
    total-hours: uint,
    days-worked: uint,
    is-compliant: bool
  }
)

(define-map driver-violations
  { driver-id: uint, violation-id: uint }
  {
    violation-type: (string-ascii 50),
    description: (string-ascii 200),
    severity: uint,
    date: uint,
    penalty-amount: uint,
    resolved: bool
  }
)

;; Authorization check
(define-private (is-authorized)
  (is-eq tx-sender CONTRACT-OWNER)
)

;; Register new driver
(define-public (register-driver
  (name (string-ascii 100))
  (license-number (string-ascii 50))
  (license-expiry uint)
  (cdl-class (string-ascii 10))
)
  (let ((driver-id (var-get next-driver-id)))
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len license-number) u0) ERR-INVALID-INPUT)
    (asserts! (> license-expiry block-height) ERR-INVALID-INPUT)

    (map-set drivers
      { driver-id: driver-id }
      {
        name: name,
        license-number: license-number,
        license-expiry: license-expiry,
        cdl-class: cdl-class,
        hire-date: block-height,
        status: "active",
        safety-score: u100,
        total-violations: u0
      }
    )

    (var-set next-driver-id (+ driver-id u1))
    (ok driver-id)
  )
)

;; Log daily hours for driver
(define-public (log-daily-hours
  (driver-id uint)
  (date uint)
  (hours-worked uint)
  (break-time uint)
)
  (let (
    (overtime-hours (if (> hours-worked MAX-DAILY-HOURS)
                       (- hours-worked MAX-DAILY-HOURS)
                       u0))
    (is-compliant (and (<= hours-worked MAX-DAILY-HOURS) (>= break-time u30)))
  )
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? drivers { driver-id: driver-id })) ERR-DRIVER-NOT-FOUND)
    (asserts! (<= hours-worked u24) ERR-INVALID-INPUT)

    (map-set driver-hours
      { driver-id: driver-id, date: date }
      {
        hours-worked: hours-worked,
        break-time: break-time,
        overtime-hours: overtime-hours,
        is-compliant: is-compliant
      }
    )

    ;; Update weekly totals
    (update-weekly-hours driver-id date hours-worked)
  )
)

;; Update weekly hours tracking
(define-private (update-weekly-hours (driver-id uint) (date uint) (daily-hours uint))
  (let (
    (week-start (- date (mod date u7)))
    (current-weekly (default-to
      { total-hours: u0, days-worked: u0, is-compliant: true }
      (map-get? weekly-hours { driver-id: driver-id, week-start: week-start })
    ))
    (new-total (+ (get total-hours current-weekly) daily-hours))
    (new-days (+ (get days-worked current-weekly) u1))
    (weekly-compliant (and (<= new-total MAX-WEEKLY-HOURS) (get is-compliant current-weekly)))
  )
    (map-set weekly-hours
      { driver-id: driver-id, week-start: week-start }
      {
        total-hours: new-total,
        days-worked: new-days,
        is-compliant: weekly-compliant
      }
    )
    (ok true)
  )
)

;; Record driver violation
(define-public (record-violation
  (driver-id uint)
  (violation-id uint)
  (violation-type (string-ascii 50))
  (description (string-ascii 200))
  (severity uint)
  (penalty-amount uint)
)
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? drivers { driver-id: driver-id })) ERR-DRIVER-NOT-FOUND)
    (asserts! (and (>= severity u1) (<= severity u5)) ERR-INVALID-INPUT)

    (map-set driver-violations
      { driver-id: driver-id, violation-id: violation-id }
      {
        violation-type: violation-type,
        description: description,
        severity: severity,
        date: block-height,
        penalty-amount: penalty-amount,
        resolved: false
      }
    )

    ;; Update driver's total violations and safety score
    (update-driver-safety-score driver-id severity)
  )
)

;; Update driver safety score based on violation
(define-private (update-driver-safety-score (driver-id uint) (severity uint))
  (let (
    (driver-data (unwrap! (map-get? drivers { driver-id: driver-id }) ERR-DRIVER-NOT-FOUND))
    (current-score (get safety-score driver-data))
    (current-violations (get total-violations driver-data))
    (score-reduction (* severity u5))
    (new-score (if (>= current-score score-reduction)
                  (- current-score score-reduction)
                  u0))
  )
    (map-set drivers
      { driver-id: driver-id }
      (merge driver-data {
        safety-score: new-score,
        total-violations: (+ current-violations u1)
      })
    )
    (ok true)
  )
)

;; Update driver status
(define-public (update-driver-status (driver-id uint) (new-status (string-ascii 20)))
  (let ((driver-data (unwrap! (map-get? drivers { driver-id: driver-id }) ERR-DRIVER-NOT-FOUND)))
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)

    (map-set drivers
      { driver-id: driver-id }
      (merge driver-data { status: new-status })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-driver (driver-id uint))
  (map-get? drivers { driver-id: driver-id })
)

(define-read-only (get-driver-hours (driver-id uint) (date uint))
  (map-get? driver-hours { driver-id: driver-id, date: date })
)

(define-read-only (get-weekly-hours (driver-id uint) (week-start uint))
  (map-get? weekly-hours { driver-id: driver-id, week-start: week-start })
)

(define-read-only (get-driver-violation (driver-id uint) (violation-id uint))
  (map-get? driver-violations { driver-id: driver-id, violation-id: violation-id })
)

(define-read-only (check-hos-compliance (driver-id uint) (date uint))
  (let (
    (daily-hours (map-get? driver-hours { driver-id: driver-id, date: date }))
    (week-start (- date (mod date u7)))
    (weekly-hours-data (map-get? weekly-hours { driver-id: driver-id, week-start: week-start }))
  )
    {
      daily-compliant: (match daily-hours hours (get is-compliant hours) true),
      weekly-compliant: (match weekly-hours-data hours (get is-compliant hours) true)
    }
  )
)

(define-read-only (get-next-driver-id)
  (var-get next-driver-id)
)
