module.exports = {
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: 'coverage',
      outputName: 'junit.xml'
    }]
  ],
  projects: [
    {
      displayName: 'server',
      testEnvironment: 'node',
      testMatch: [
        '**/tests/server.test.js',
        '**/tests/integration.test.js'
      ],
      collectCoverageFrom: [
        'server.js',
        '!**/node_modules/**',
        '!**/coverage/**'
      ],
      coverageDirectory: 'coverage/server',
      setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
    },
    {
      displayName: 'client',
      testEnvironment: 'jsdom',
      testMatch: [
        '**/tests/client.test.js'
      ],
      collectCoverageFrom: [
        'public/script.js',
        '!**/node_modules/**',
        '!**/coverage/**'
      ],
      coverageDirectory: 'coverage/client',
      setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
    }
  ]
};
