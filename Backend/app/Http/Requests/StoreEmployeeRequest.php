<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreEmployeeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:employees,email'],
            'department' => ['required', 'string', 'max:255'],
            'designation' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'joining_date' => ['required', 'date'],
            'is_active' => ['sometimes', 'boolean'],
            'avatar_url' => ['nullable', 'string', 'max:500', 'url'],
        ];
    }
}
