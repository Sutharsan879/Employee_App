<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\DB;

class Employee extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'department',
        'designation',
        'phone',
        'joining_date',
        'is_active',
        'avatar_url',
    ];

    protected $casts = [
        'joining_date' => 'date',
        'is_active' => 'boolean',
    ];

    protected $appends = [
        'years_of_service',
        'is_flagged',
    ];

    public function getYearsOfServiceAttribute(): int
    {
        return (int) Carbon::parse($this->joining_date)->diffInYears(Carbon::today());
    }

    public function getIsFlaggedAttribute(): bool
    {
        return $this->is_active && $this->years_of_service > 5;
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    public function scopeFlagged(Builder $query): Builder
    {
        $query->where('is_active', true);

        if (DB::connection()->getDriverName() === 'mysql') {
            return $query->whereRaw('TIMESTAMPDIFF(YEAR, joining_date, CURDATE()) > 5');
        }

        return $query->whereDate('joining_date', '<=', Carbon::today()->subYears(6));
    }
}
