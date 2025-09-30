;; middleware-registry
;; 
;; This contract provides a secure, immutable tracking system for service middleware interactions.
;; It allows service providers to register their middleware platforms, add authorized interactions,
;; and record cryptographic proofs of service activities without storing sensitive data on-chain.
;; The contract serves as a tamper-proof record for verification and interaction tracking.

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-SERVICE-PLATFORM-ALREADY-REGISTERED (err u101))
(define-constant ERR-SERVICE-PLATFORM-NOT-REGISTERED (err u102))
(define-constant ERR-INTERACTION-ALREADY-REGISTERED (err u103))
(define-constant ERR-INTERACTION-NOT-REGISTERED (err u104))
(define-constant ERR-INVALID-INTERACTION-ACTION (err u105))
(define-constant ERR-ATTESTATION-EXISTS (err u106))

;; Data space definitions

;; Maps each service provider's middleware platform to its owner's principal
(define-map service-platforms
  principal  ;; owner
  {
    platform-id: (string-ascii 64),
    registration-time: uint
  }
)

;; Stores information about each registered service interaction
(define-map service-interactions
  {
    owner: principal,
    interaction-id: (string-ascii 64)
  }
  {
    interaction-name: (string-ascii 64),
    interaction-type: (string-ascii 32),
    registration-time: uint
  }
)

;; Stores interaction attestations (hashes) for each service platform
(define-map interaction-logs
  {
    owner: principal,
    interaction-id: (string-ascii 64),
    timestamp: uint
  }
  {
    action-hash: (buff 32),    ;; Hash of the interaction action details
    attestation-hash: (buff 32) ;; Hash combining interaction-id, timestamp, and action for verification
  }
)

;; Tracks all interactions registered to a particular platform for easy enumeration
(define-map platform-interactions
  principal  ;; owner
  (list 100 (string-ascii 64))  ;; list of interaction-ids, max 100 interactions
)

;; Private functions

;; Checks if the Service Platform is registered to the caller
(define-private (is-service-platform-owner (owner principal))
  (is-some (map-get? service-platforms owner))
)

;; Validates if an interaction is registered to the owner
(define-private (is-interaction-registered (owner principal) (interaction-id (string-ascii 64)))
  (is-some (map-get? service-interactions {owner: owner, interaction-id: interaction-id}))
)

;; Public functions

;; Registers a new Service Platform for the provider
(define-public (register-service-platform (platform-id (string-ascii 64)))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-none (map-get? service-platforms caller)) ERR-SERVICE-PLATFORM-ALREADY-REGISTERED)
    
    (map-set service-platforms caller {
      platform-id: platform-id,
      registration-time: block-height
    })
    
    (ok true)
  )
)

;; Records an interaction attestation for a service platform
(define-public (log-service-interaction 
    (interaction-id (string-ascii 64))
    (timestamp uint)
    (action-hash (buff 32))
    (attestation-hash (buff 32)))
  (let (
    (caller tx-sender)
    (log-key {owner: caller, interaction-id: interaction-id, timestamp: timestamp})
  )
    ;; Check that caller has a registered Service Platform
    (asserts! (is-service-platform-owner caller) ERR-SERVICE-PLATFORM-NOT-REGISTERED)
    ;; Check that interaction is registered
    (asserts! (is-interaction-registered caller interaction-id) ERR-INTERACTION-NOT-REGISTERED)
    ;; Ensure this exact log doesn't already exist
    (asserts! (is-none (map-get? interaction-logs log-key)) ERR-ATTESTATION-EXISTS)
    
    ;; Store the interaction attestation
    (map-set interaction-logs log-key
      {
        action-hash: action-hash,
        attestation-hash: attestation-hash
      }
    )
    
    (ok true)
  )
)

;; Read-only functions

;; Gets details of a registered Service Platform
(define-read-only (get-platform-info (owner principal))
  (map-get? service-platforms owner)
)

;; Gets details of a registered service interaction
(define-read-only (get-interaction-info (owner principal) (interaction-id (string-ascii 64)))
  (map-get? service-interactions {owner: owner, interaction-id: interaction-id})
)

;; Gets all interactions registered to a platform
(define-read-only (get-platform-interactions (owner principal))
  (default-to (list) (map-get? platform-interactions owner))
)

;; Retrieves a specific interaction log
(define-read-only (get-interaction-log (owner principal) (interaction-id (string-ascii 64)) (timestamp uint))
  (map-get? interaction-logs {owner: owner, interaction-id: interaction-id, timestamp: timestamp})
)

;; Verifies if a provided attestation matches the stored one
(define-read-only (verify-interaction-attestation 
    (owner principal)
    (interaction-id (string-ascii 64))
    (timestamp uint)
    (provided-attestation-hash (buff 32)))
  (let (
    (log-entry (map-get? interaction-logs {owner: owner, interaction-id: interaction-id, timestamp: timestamp}))
  )
    (and
      (is-some log-entry)
      (is-eq provided-attestation-hash (get attestation-hash (unwrap-panic log-entry)))
    )
  )
)

;; Checks if an interaction was active at a specific time by verifying existence of a log
(define-read-only (was-interaction-active (owner principal) (interaction-id (string-ascii 64)) (timestamp uint))
  (is-some (map-get? interaction-logs {owner: owner, interaction-id: interaction-id, timestamp: timestamp}))
)