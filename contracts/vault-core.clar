;; VaultCore: Enterprise Bitcoin Collateralization Platform
;; 
;; Summary:
;; Advanced DeFi protocol enabling Bitcoin holders to unlock liquidity through
;; over-collateralized lending positions while maintaining BTC exposure.
;; 
;; Description:
;; VaultCore revolutionizes Bitcoin utility by transforming idle BTC holdings
;; into productive capital. Users deposit Bitcoin as collateral to mint USD-
;; pegged stablecoins, creating sophisticated debt positions with dynamic
;; interest rates, automated risk management, and liquidation protection.
;; The protocol features real-time price oracles, compound interest mechanics,
;; and a robust liquidation engine designed for institutional-grade reliability.
;;
;; Key Features:
;; - Over-collateralized lending with 150% minimum ratio
;; - Automated liquidation at 120% threshold with 10% penalty
;; - Compound interest accrual per block (~10% APR)
;; - Oracle-based pricing with 24-hour validity windows
;; - Emergency pause functionality for protocol security
;; - Transparent fee collection and protocol statistics

;; ERROR CONSTANTS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1001))
(define-constant ERR-POSITION-NOT-FOUND (err u1002))
(define-constant ERR-UNDERCOLLATERALIZED (err u1003))
(define-constant ERR-MINIMUM-LOAN-REQUIRED (err u1004))
(define-constant ERR-INSUFFICIENT-DEBT (err u1005))
(define-constant ERR-PRICE-EXPIRED (err u1006))
(define-constant ERR-PROTOCOL-PAUSED (err u1007))
(define-constant ERR-INVALID-AMOUNT (err u1008))
(define-constant ERR-NO-PRICE-DATA (err u1009))

;; PROTOCOL PARAMETERS
(define-constant COLLATERAL-RATIO u150)              ;; 150% minimum collateral ratio
(define-constant LIQUIDATION-THRESHOLD u120)         ;; 120% liquidation threshold
(define-constant LIQUIDATION-PENALTY u10)            ;; 10% liquidation penalty
(define-constant MINIMUM_LOAN_AMOUNT u100000000)     ;; 100 stablecoins (8 decimals)
(define-constant PRICE_EXPIRY u86400)                ;; 24-hour price validity
(define-constant INTEREST_RATE_PER_BLOCK u5)         ;; 0.0005% per block (~10% APR)
(define-constant INTEREST_RATE_DENOMINATOR u1000000) ;; Interest rate precision

;; STATE VARIABLES
(define-data-var protocol-owner principal tx-sender)
(define-data-var protocol-paused bool false)
(define-data-var total-debt uint u0)
(define-data-var total-collateral uint u0)
(define-data-var stability-fee uint u0)
(define-data-var last-accrual-block uint stacks-block-height)
(define-data-var btc-price-in-usd (optional {price: uint, timestamp: uint}) none)
(define-data-var current-time uint u0) ;; Mock time for testing

;; DATA STRUCTURES
(define-map positions principal {
  collateral: uint,           ;; BTC collateral in satoshis
  debt: uint,                 ;; Stablecoin debt amount
  last-update-block: uint     ;; Last interest calculation block
})

;; FUNGIBLE TOKEN
(define-fungible-token stable-usd)

;; ADMINISTRATIVE FUNCTIONS

(define-public (set-protocol-owner (new-owner principal))
  ;; Transfer protocol ownership to a new principal
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set protocol-owner new-owner))
  )
)

(define-public (pause-protocol (paused bool))
  ;; Emergency pause/unpause protocol operations
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set protocol-paused paused))
  )
)

(define-public (update-btc-price (price uint) (timestamp uint))
  ;; Update BTC/USD price from oracle feed
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> price u0) ERR-INVALID-AMOUNT)
    (var-set btc-price-in-usd (some {price: price, timestamp: timestamp}))
    (ok true)
  )
)

(define-public (set-current-time (time uint))
  ;; Set current timestamp for testing purposes
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set current-time time))
  )
)

;; UTILITY FUNCTIONS

(define-private (collateral-value (collateral-amount uint) (price uint))
  ;; Calculate USD value of BTC collateral
  (* collateral-amount price)
)

(define-private (required-collateral (debt-amount uint) (price uint))
  ;; Calculate minimum collateral required for given debt
  (/ (* debt-amount COLLATERAL-RATIO) (/ price u100))
)

(define-private (is-position-safe (user principal) (btc-price uint))
  ;; Check if position meets minimum collateralization requirements
  (let (
    (position (unwrap! (map-get? positions user) false))
    (debt (get debt position))
    (collateral (get collateral position))
    (collateral-value-usd (collateral-value collateral btc-price))
    (min-collateral-value-usd (/ (* debt COLLATERAL-RATIO) u100))
  )
    (>= collateral-value-usd min-collateral-value-usd)
  )
)

(define-private (calculate-interest (debt uint) (blocks-passed uint))
  ;; Calculate compound interest for given debt over time
  (/ (* debt (* blocks-passed INTEREST_RATE_PER_BLOCK)) INTEREST_RATE_DENOMINATOR)
)

(define-private (accrue-global-interest)
  ;; Update protocol-wide interest accumulation
  (let (
    (current-block stacks-block-height)
    (last-block (var-get last-accrual-block))
    (blocks-passed (- current-block last-block))
    (total-system-debt (var-get total-debt))
    (interest-accrued (calculate-interest total-system-debt blocks-passed))
  )
    (begin
      (if (> blocks-passed u0)
        (begin
          (var-set stability-fee (+ (var-get stability-fee) interest-accrued))
          (var-set total-debt (+ total-system-debt interest-accrued))
          (var-set last-accrual-block current-block)
        )
        false
      )
      true
    )
  )
)

(define-private (accrue-position-interest (user principal))
  ;; Update individual position with accrued interest
  (let (
    (position (unwrap! (map-get? positions user) 
      {debt: u0, collateral: u0, last-update-block: stacks-block-height}))
    (debt (get debt position))
    (collateral (get collateral position))
    (last-update (get last-update-block position))
    (blocks-passed (- stacks-block-height last-update))
    (interest-accrued (calculate-interest debt blocks-passed))
    (new-debt (+ debt interest-accrued))
    (updated-position {
      collateral: collateral,
      debt: new-debt,
      last-update-block: stacks-block-height
    })
  )
    (begin
      (if (> blocks-passed u0)
        (map-set positions user updated-position)
        false
      )
      updated-position
    )
  )
)

(define-read-only (get-current-price)
  ;; Retrieve current BTC price with expiry validation
  (match (var-get btc-price-in-usd)
    price-data (let (
      (price (get price price-data))
      (timestamp (get timestamp price-data))
      (current-timestamp (var-get current-time))
    )
      (if (>= (- current-timestamp timestamp) PRICE_EXPIRY)
        ERR-PRICE-EXPIRED
        (if (<= price u0)
          ERR-PRICE-EXPIRED
          (ok price)
        )
      ))
    ERR-NO-PRICE-DATA
  )
)