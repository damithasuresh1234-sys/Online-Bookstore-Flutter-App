<?php
/**
 * Simple validation helper to enforce data integrity across endpoints.
 */
class Validator
{
    private array $errors = [];
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function required(string $field, string $label = null): self
    {
        $label = $label ?? $field;
        if (!isset($this->data[$field]) || trim((string)$this->data[$field]) === '') {
            $this->errors[] = "$label is required.";
        }
        return $this;
    }

    public function email(string $field): self
    {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
            $this->errors[] = "A valid email address is required.";
        }
        return $this;
    }

    public function minLength(string $field, int $length, string $label = null): self
    {
        $label = $label ?? $field;
        if (isset($this->data[$field]) && strlen((string)$this->data[$field]) < $length) {
            $this->errors[] = "$label must be at least $length characters.";
        }
        return $this;
    }

    public function numeric(string $field, string $label = null): self
    {
        $label = $label ?? $field;
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->errors[] = "$label must be a number.";
        }
        return $this;
    }

    public function min(string $field, float $min, string $label = null): self
    {
        $label = $label ?? $field;
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] < $min) {
            $this->errors[] = "$label must be at least $min.";
        }
        return $this;
    }

    public function in(string $field, array $allowed, string $label = null): self
    {
        $label = $label ?? $field;
        if (isset($this->data[$field]) && !in_array($this->data[$field], $allowed, true)) {
            $this->errors[] = "$label must be one of: " . implode(', ', $allowed) . ".";
        }
        return $this;
    }

    public function fails(): bool
    {
        return count($this->errors) > 0;
    }

    public function getErrors(): array
    {
        return $this->errors;
    }
}
