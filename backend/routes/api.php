<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\FinancingController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SavingController;
use App\Http\Controllers\Api\SocialFundController;
use Illuminate\Support\Facades\Route;

/*
|----------------------------------------------------------------------
| API Routes - KBMT Koperasi
| Format response: { success, message, data }
|----------------------------------------------------------------------
*/

// ===================== PUBLIC =====================
Route::prefix('auth')->middleware('throttle:10,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password',  [AuthController::class, 'resetPassword']);
});

// ===================== AUTHENTICATED =====================
Route::middleware('auth:sanctum')->group(function () {
    // ---------- Auth & Profile ----------
    Route::prefix('auth')->group(function () {
        Route::post('/logout',  [AuthController::class, 'logout']);
        Route::get('/profile',  [AuthController::class, 'profile']);
        Route::post('/profile', [AuthController::class, 'updateProfile']); // pakai POST untuk mendukung multipart (foto)
        Route::put('/profile',  [AuthController::class, 'updateProfile']);
    });

    // ---------- Dashboards ----------
    Route::get('/dashboard/member', [DashboardController::class, 'member']);

    // ---------- Notifications ----------
    Route::prefix('notifications')->group(function () {
        Route::get('/',                  [NotificationController::class, 'index']);
        Route::post('/{id}/read',        [NotificationController::class, 'markAsRead']);
        Route::post('/read-all',         [NotificationController::class, 'markAllAsRead']);
    });

    // ---------- Member self-service savings ----------
    Route::prefix('savings')->group(function () {
        Route::get('/balance',   [SavingController::class, 'balance']);
        Route::get('/mandatory', [SavingController::class, 'mandatorySavings']);
        Route::get('/principal', [SavingController::class, 'principalSaving']);
    });

    // ---------- Financing (member can list own & apply, simulate) ----------
    Route::prefix('financing')->group(function () {
        Route::get('/',                  [FinancingController::class, 'index']);
        Route::post('/simulate',         [FinancingController::class, 'simulate']);
        Route::post('/',                 [FinancingController::class, 'store']);
        Route::get('/{financing}',       [FinancingController::class, 'show']);
        Route::get('/{financing}/installments', [FinancingController::class, 'installments']);
    });

    // ---------- Products & Categories (read for everyone) ----------
    Route::get('/categories',          [ProductController::class, 'categories']);
    Route::get('/categories/{category}', [ProductController::class, 'showCategory']);
    Route::get('/products',            [ProductController::class, 'index']);
    Route::get('/products/{product}',  [ProductController::class, 'show']);

    // ---------- Social Fund ----------
    Route::prefix('social-funds')->group(function () {
        Route::get('/',                       [SocialFundController::class, 'index']);
        Route::get('/applications',           [SocialFundController::class, 'applications']);
        Route::post('/applications',          [SocialFundController::class, 'storeApplication']);
        Route::get('/applications/{application}', [SocialFundController::class, 'showApplication']);
    });

    // ===================== ADMIN ONLY =====================
    Route::middleware(\App\Http\Middleware\AdminMiddleware::class)->group(function () {
        // Dashboard
        Route::get('/dashboard/admin', [DashboardController::class, 'admin']);

        // Members CRUD
        Route::apiResource('members', MemberController::class);

        // Savings management
        Route::prefix('savings')->group(function () {
            Route::post('/deposit',         [SavingController::class, 'deposit']);
            Route::post('/withdraw',        [SavingController::class, 'withdraw']);
            Route::post('/mandatory/pay',   [SavingController::class, 'payMandatorySaving']);
        });
        Route::get('/admin/savings',           [SavingController::class, 'allSavings']);
        Route::get('/admin/mandatory-savings', [SavingController::class, 'allMandatorySavings']);

        // Financing management
        Route::put('/financing/{financing}/approve', [FinancingController::class, 'approve']);
        Route::put('/financing/{financing}/reject',  [FinancingController::class, 'reject']);
        Route::post('/financing/{financing}/pay',    [FinancingController::class, 'payInstallment']);

        // Categories CRUD
        Route::post('/categories',                [ProductController::class, 'storeCategory']);
        Route::put('/categories/{category}',      [ProductController::class, 'updateCategory']);
        Route::delete('/categories/{category}',   [ProductController::class, 'destroyCategory']);

        // Products CRUD (POST + multipart for image; allow PUT also)
        Route::post('/products',           [ProductController::class, 'store']);
        Route::post('/products/{product}', [ProductController::class, 'update']);
        Route::put('/products/{product}',  [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);

        // Social Funds (admin)
        Route::post('/social-funds',                                         [SocialFundController::class, 'store']);
        Route::put('/social-funds/applications/{application}/decide',        [SocialFundController::class, 'decideApplication']);

        // Reports (PDF & Excel) - format=pdf|excel
        Route::prefix('reports')->group(function () {
            Route::get('/members',      [ReportController::class, 'members']);
            Route::get('/savings',      [ReportController::class, 'savings']);
            Route::get('/financings',   [ReportController::class, 'financings']);
            Route::get('/social-funds', [ReportController::class, 'socialFunds']);
        });
    });
});
