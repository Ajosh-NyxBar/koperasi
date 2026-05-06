<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Services\MemberService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(
        private AuthService $auth,
        private MemberService $memberService,
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->register($request->validated());
        return $this->created([
            'user'  => UserResource::make($result['user']),
            'token' => $result['token'],
        ], 'Registrasi berhasil');
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->login($request->email, $request->password);
        return $this->success([
            'user'  => UserResource::make($result['user']),
            'token' => $result['token'],
        ], 'Login berhasil');
    }

    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($request->user());
        return $this->success(null, 'Logout berhasil');
    }

    public function profile(Request $request): JsonResponse
    {
        return $this->success(UserResource::make($request->user()->load('member')));
    }

    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validated();

        if (isset($data['password'])) {
            if (!Hash::check($data['current_password'] ?? '', $user->password)) {
                throw ValidationException::withMessages(['current_password' => ['Password saat ini salah.']]);
            }
            $user->password = Hash::make($data['password']);
        }
        if (isset($data['name'])) $user->name = $data['name'];
        if (isset($data['email'])) $user->email = $data['email'];
        $user->save();

        // Update member fields
        if ($member = $user->member) {
            $memberFields = collect($data)->only(['phone', 'address', 'birth_date', 'birth_place', 'occupation', 'monthly_income'])->toArray();
            if (!empty($memberFields)) $member->update($memberFields);
            if (isset($data['name'])) $member->update(['full_name' => $data['name']]);
            if ($request->hasFile('photo')) {
                $this->memberService->uploadPhoto($member, $request->file('photo'));
            }
        }

        return $this->success(UserResource::make($user->fresh()->load('member')), 'Profil berhasil diperbarui');
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $result = $this->auth->sendPasswordOtp($request->email);
        // token dikembalikan supaya bisa dipakai langsung di reset (juga dikirim via email)
        return $this->success(['token' => $result['token']], 'Kode OTP telah dikirim ke email');
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $result = $this->auth->verifyOtp($request->email, $request->otp);
        return $this->success(['token' => $result['token']], 'OTP valid');
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $this->auth->resetPassword($request->email, $request->token, $request->password);
        return $this->success(null, 'Password berhasil direset');
    }
}
