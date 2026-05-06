<?php

namespace App\Services;

use App\Models\Member;
use App\Models\PasswordOtp;
use App\Models\PrincipalSaving;
use App\Models\Saving;
use App\Models\User;
use App\Notifications\PasswordResetOtpNotification;
use App\Repositories\MemberRepository;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(private MemberRepository $memberRepo) {}

    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['full_name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'role' => 'member',
            ]);

            $member = Member::create([
                'user_id'        => $user->id,
                'member_code'    => $this->memberRepo->generateCode(),
                'full_name'      => $data['full_name'],
                'nik'            => $data['nik'],
                'phone'          => $data['phone'] ?? null,
                'address'        => $data['address'] ?? null,
                'gender'         => $data['gender'],
                'birth_date'     => $data['birth_date'] ?? null,
                'birth_place'    => $data['birth_place'] ?? null,
                'occupation'     => $data['occupation'] ?? null,
                'monthly_income' => $data['monthly_income'] ?? null,
                'join_date'      => now(),
                'status'         => 'active',
            ]);

            Saving::create(['member_id' => $member->id, 'balance' => 0]);
            PrincipalSaving::create([
                'member_id' => $member->id,
                'amount'    => 100000,
                'status'    => 'unpaid',
            ]);

            $token = $user->createToken('kbmt-app')->plainTextToken;

            return ['user' => $user->load('member'), 'token' => $token];
        });
    }

    public function login(string $email, string $password): array
    {
        $user = User::where('email', $email)->first();

        if (!$user || !Hash::check($password, $user->password)) {
            throw ValidationException::withMessages(['email' => ['Email atau password salah.']]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages(['email' => ['Akun dinonaktifkan.']]);
        }

        $token = $user->createToken('kbmt-app')->plainTextToken;
        return ['user' => $user->load('member'), 'token' => $token];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    public function sendPasswordOtp(string $email): array
    {
        $user = User::where('email', $email)->firstOrFail();
        $otp = (string) random_int(100000, 999999);
        $token = Str::random(64);

        PasswordOtp::create([
            'email'      => $email,
            'otp'        => $otp,
            'token'      => $token,
            'expires_at' => now()->addMinutes(10),
        ]);

        $user->notify(new PasswordResetOtpNotification($otp, $token));

        return ['token' => $token];
    }

    public function verifyOtp(string $email, string $otp): array
    {
        $record = PasswordOtp::where('email', $email)
            ->where('otp', $otp)
            ->whereNull('used_at')
            ->orderByDesc('id')
            ->first();

        if (!$record || $record->isExpired()) {
            throw ValidationException::withMessages(['otp' => ['Kode OTP salah atau kedaluwarsa.']]);
        }

        return ['token' => $record->token];
    }

    public function resetPassword(string $email, string $token, string $password): void
    {
        $record = PasswordOtp::where('email', $email)
            ->where('token', $token)
            ->whereNull('used_at')
            ->first();

        if (!$record || $record->isExpired()) {
            throw ValidationException::withMessages(['token' => ['Token reset tidak valid atau kedaluwarsa.']]);
        }

        $user = User::where('email', $email)->firstOrFail();
        $user->update(['password' => Hash::make($password)]);
        $record->update(['used_at' => now()]);
        $user->tokens()->delete();
    }
}
