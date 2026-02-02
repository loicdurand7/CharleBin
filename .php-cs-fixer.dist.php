<?php

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__ . '/lib');

return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12' => true,
    ])
    ->setFinder($finder);
